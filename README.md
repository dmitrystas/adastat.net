# adastat.net
This is a repository for keeping track of issues and feature requests for AdaStat

## Using send_pool_blocks.sh
Pool operators can provide the information about the number of slots (blocks) assigned to their pool for the current epoch

This will show your concern for your delegators who will be able to see the number blocks the pool should create in the current epoch

![pool_blocks](images/pool_blocks.png)

Sending blocks every epoch will also allow us to calculate the ROS of your pool more accurately

To send the blocks quantity please download [send_pool_blocks.sh](./files/send_pool_blocks.sh), define the config variables with your own data and run it

> We recommend to send the blocks 5-15 minutes after the beginning of the epoch, because the leaders logs on your node may be updated with a slight delay, so if you send blocks immediately after the beginning of the epoch, they may still be empty

No registration on https://adastat.net/ required
