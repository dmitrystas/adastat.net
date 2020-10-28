<?php

$pool_id = 'adb8f11466290d1a8bef7c9665848cd66e45a7e74e5c25f586f0192e';

$sourceFile = __DIR__ . '/ledger_state.json';

system('cardano-cli shelley query ledger-state --mainnet --cardano-mode --out-file ' . $sourceFile);

$json = json_decode(file_get_contents($sourceFile));

$delegators = array();

foreach ($json->esSnapshots->_pstakeMark->_delegations as $row) {
	if (is_array($row) && count($row) == 2 && $row[1] == $pool_id && is_object($row[0])) {
		$delegator = trim($row[0]->{'key hash'});
		if ($delegator) {
			$delegators[$delegator] = $delegator;
		}
	}
}

foreach ($json->esSnapshots->_pstakeMark->_stake as $row) {
	if (is_array($row) && count($row) == 2 && is_object($row[0]) && isset($delegators[$row[0]->{'key hash'}])) {
		if ($row[1] > 0) {
			$delegators[$row[0]->{'key hash'}] = $row[1];
		} else {
			unset($delegators[$row[0]->{'key hash'}]);
		}
	}
}

asort($delegators);

$count = count($delegators);

$amount = array_sum($delegators);

$crc32 = crc32($count.$amount);

$winnerIndex = $crc32 / hexdec('FFFFFFFF');

$index = 0;

foreach ($delegators as $key=>$val) {
	$percent = $val / $amount;
	$index += $percent;
	if ($index >= $winnerIndex) {
		echo 'Winner account: https://adastat.net/accounts/' . $key . PHP_EOL;
		break;
	}
}
