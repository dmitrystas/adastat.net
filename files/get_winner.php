<?php

$epoch_nonce = 'e8ab287be691fa28865e118ed34d904349229215865e5d3113ca9ec880880796';

$pool_id = '77b0a93c26ac65be36e9a9f220f9a43cbc57d705fc5d8f1de5fdeea1';

$ledgerFile = __DIR__ . '/ledger.json';

system('cardano-cli query ledger-state --mainnet > ' . $ledgerFile);

$json = json_decode(file_get_contents($ledgerFile));

$delegators = array();

foreach ($json->stateBefore->esSnapshots->pstakeMark->delegations as $row) {
	if (is_array($row) && count($row) == 2 && $row[1] == $pool_id && is_object($row[0])) {
		$delegator = trim($row[0]->{'key hash'});
		if ($delegator) {
			$delegators[$delegator] = $delegator;
		}
	}
}

foreach ($json->stateBefore->esSnapshots->pstakeMark->stake as $row) {
	if (is_array($row) && count($row) == 2 && is_object($row[0]) && isset($delegators[$row[0]->{'key hash'}])) {
		if ($row[1] > 0) {
			$delegators[$row[0]->{'key hash'}] = $row[1];
		} else {
			unset($delegators[$row[0]->{'key hash'}]);
		}
	}
}

ksort($delegators);

for ($winner=1; $winner<=5; $winner++) {
	$totalStake = array_sum($delegators);

	$winnerPos = $totalStake * crc32($epoch_nonce . $winner) / 4294967296;

	$stakePos = 0;
	
	foreach ($delegators as $hash => $stake) {
		$stakePos += $stake;
		if ($stakePos > $winnerPos) {
			echo 'Winner account '  . $winner . ': https://adastat.net/accounts/' . $hash . PHP_EOL;
			unset($delegators[$hash]);
			break;
		}
	}	
}
