# Week 6: Load Test Report

I put PropertyLite behind an Application Load Balancer, with an Auto Scaling group of t3.micro instances in the private subnets of my VPC (desired 2, min 1, max 4). The group uses a target tracking policy that keeps average CPU at 50%. Through the load balancer, `/health` returned `{"status":"ok"}` and `/properties` returned the listings, with traffic spread across both instances.

To test scaling, I SSHed into both instances through the bastion and ran `stress-ng --cpu 2` on each, which pushed average CPU close to 100% (`cpu-spike.png`). My first run didn't scale at all because the scaling policy hadn't been created, so there was no CloudWatch alarm to trigger it. After adding the policy, I ran the test again.

- Stress started: 1:57:56 AM PST (09:57:56 UTC) on the first instance, then on the second about two minutes later
- CPU alarm went into ALARM: 2:03:12 AM PST (10:03:12 UTC)
- First scale-out (2 to 3 instances) started: 2:03:23 AM PST
- Second scale-out (3 to 4 instances) started: 2:05:21 AM PST
- Time gap from stress start to first scale-out: about 5 minutes 30 seconds

The gap comes from how target tracking works. The alarm needs 3 datapoints in a row above 50% before it fires, CloudWatch metrics arrive a minute or so late, and average CPU only crossed 50% once both instances were stressed. Once the alarm fired, Auto Scaling launched a new instance within about 10 seconds. CPU stayed high, so it added a fourth instance two minutes later and stopped there because 4 is the group's max. I turned on detailed monitoring in the launch template, which sends metrics every minute instead of every 5 and kept the delay short.
