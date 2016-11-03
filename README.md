# Convox: Sinatra & Redis

This application includes:

* Sinatra web app
* Redis-based worker

## Development

    $ convox start

## Production

[See docs](http://docs.convox.com/docs/)

### Rack creation
```
$ convox install --stack-name foobar0

     ___    ___     ___   __  __    ___   __  _
    / ___\ / __ \ /  _  \/\ \/\ \  / __ \/\ \/ \
   /\ \__//\ \_\ \/\ \/\ \ \ \_/ |/\ \_\ \/>  </
   \ \____\ \____/\ \_\ \_\ \___/ \ \____//\_/\_\
    \/____/\/___/  \/_/\/_/\/__/   \/___/ \//\/_/


Installing Convox (20161102160040)...
Email Address (optional, to receive project updates):
Created ECS Cluster: foobar0-Cluster-**********LVE
Created CloudWatch Log Group: foobar0-LogGroup-**********V25
Created VPC Internet Gateway: igw-******99
Created VPC: vpc-*****550
Created Lambda Function: foobar0-CustomTopic-*********8Z8
Created S3 Bucket: foobar0-settings-*********0cl
Created S3 Bucket: foobar0-registrybucket-**********a7s
Created Lambda Function: foobar0-LogSubscriptionFilterFunction-********4F3P
Created Lambda Function: foobar0-InstancesLifecycleHandler-**********9U8
Created KMS Key: EncryptionKey
Created EFS Filesystem: fs-*****c3a
Created DynamoDB Table: foobar0-releases
Created DynamoDB Table: foobar0-builds
Created IAM User: foobar0-KernelUser-*********0SM
Created IAM User: foobar0-RegistryUser-*********ICQE
Created Security Group: sg-*****31f
Created Access Key: *******************A
Created Security Group: sg-*******d
Created Access Key: *******************A
Created Security Group: sg-**********b
Created Routing Table: rtb-**********4
Created VPC Subnet: subnet-**********8
Created VPC Subnet: subnet-**********c
Created VPC Subnet: subnet-**********6
Created Elastic Load Balancer: foobar0
Created ECS TaskDefinition: RackBuildTasks
Created ECS TaskDefinition: RackMonitorTasks
Created ECS TaskDefinition: RackWebTasks
Created AutoScalingGroup: foobar0-Instances-*********K4Q
Created ECS Service: RackMonitor
Created ECS Service: RackWeb
Created CloudFormation Stack: foobar0
Waiting for load balancer...
.Logging in...
Success, try `convox apps`

```

### Rack registration
```
$ cat ~/.convox/host
foobar0-*********8.eu-west-1.elb.amazonaws.com
```

### App creation
```
$ convox apps create app0
Creating app app0... CREATING
```

```
$ convox apps info
Name       app0
Status     running
Release    (none)
Processes  (none)
Endpoints
```

### Build an app (incremental)
```
$ convox build --app app0 --rack foobar0--description "development:$(date +%Y%m%d%H%M%S)" --incremental

Analyzing source... OK
Identifying changes... 36 files
OK
Starting build... OK
Authenticating ************.***.***.eu-west-1.amazonaws.com: Login Succeeded

running: docker build -f /tmp/971230507/Dockerfile -t app0/web /tmp/971230507
Sending build context to Docker daemon 64.51 kB
Step 1 : FROM ruby:2.3
...
redis.BFBLLKPPXOY: digest: sha256:c164499212aab4fa729a8aac3fabe6de88e0fdc15276f6e180c8f4c1b348399c size: 8487
...
web.BFBLLKPPXOY: digest: sha256:71a0565c1774fe102ea786fe6cca3d174b12d92166d945ff7790f2a92558886a size: 17182
...
worker.BFBLLKPPXOY: digest: sha256:d9aaeb909dd2ba45e4e4a1ed8253f5f9e9aa7a0e4ab9f0194d27250b70604542 size: 17185
...
Release: RCSICZFUNRN
```

### Builds list
```
$ convox builds
ID           STATUS    RELEASE      STARTED         ELAPSED  DESC
BFBLLKPPXOY  complete  RCSICZFUNRN  10 minutes ago  3m51s    development:20161103101150
```

### Releases list
```
$ convox releases
ID           CREATED        BUILD        STATUS
RCSICZFUNRN  5 minutes ago  BFBLLKPPXOY

$ convox releases info RCSICZFUNRN
Id       RCSICZFUNRN
Build    BFBLLKPPXOY
Created  2016-11-03 09:15:45.310053838 +0000 UTC
Env
```

### Promote (deploy)
```
$ convox releases promote RCSICZFUNRN
Promoting RCSICZFUNRN... UPDATING
```

```
$ convox releases
ID           CREATED         BUILD        STATUS
RCSICZFUNRN  15 minutes ago  BFBLLKPPXOY  active
```

### App info
```
$ convox apps info
Name       app0
Status     updating
Release    RCSICZFUNRN
Processes  redis web worker
Endpoints  :6379 (redis)
           :80 (web)
           :443 (web)

$ convox apps info
Name       app0
Status     running
Release    RCSICZFUNRN
Processes  redis web worker
Endpoints  app0-web-********-*********.eu-west-1.elb.amazonaws.com:80 (web)
           app0-web-********-*********.eu-west-1.elb.amazonaws.com:443 (web)
           internal-app0-redis-*******-i-********.eu-west-1.elb.amazonaws.com:6379 (redis)
```

### Scale
```
$ convox scale --app app0 --rack foobar0
NAME    DESIRED  RUNNING  CPU  MEMORY
web     1        1        0    256
worker  1        1        0    256
redis   1        1        0    256
```

### Deploy a new release
```
$ convox deploy --app app0 --rack foobar0 --description "development:$(date +%Y%m%d%H%M%S)" --incremental

Deploying app0
Analyzing source... OK
Identifying changes... 3 files
OK
Starting build... OK

...
redis.BNSYTPOLJJO: digest: sha256:1c694809b099f5a2cc3edc2a699ffc39e750f62043417d3fd4d695052a8041cb size: 8487
...
web.BNSYTPOLJJO: digest: sha256:6c2bad50c2ba53603a9ad01c4df50a3ba1337c6a07a15a7e879d44a6bd794224 size: 17182
...
worker.BNSYTPOLJJO: digest: sha256:fe3cea7d33a80dc8c130fc8d7b12df2cbfd00be2393608470dbe47a945f26aa1 size: 17185

Promoting RSFMQELEDBM... UPDATING
```

```
$ convox releases
ID           CREATED         BUILD        STATUS
RSFMQELEDBM  1 minute ago    BNSYTPOLJJO  active
RCSICZFUNRN  32 minutes ago  BFBLLKPPXOY
```

```
$ convox builds
ID           STATUS    RELEASE      STARTED         ELAPSED  DESC
BNSYTPOLJJO  complete  RSFMQELEDBM  1 minute ago    11s      development:20161103104630
BFBLLKPPXOY  complete  RCSICZFUNRN  36 minutes ago  3m51s    development:20161103101150
```

### Logs
```
$ convox logs --app app0 --rack foobar0

2016-11-03T10:17:03Z web:RSVTCTUSURT/********73 10.0.3.78 - - [03/Nov/2016:10:17:03 +0000] "GET / HTTP/1.1" 200 1258 0.0055
2016-11-03T10:17:09Z web:RSVTCTUSURT/********73 message received: {"text"=>"lol"} and pushing into convox.queue
2016-11-03T10:17:09Z web:RSVTCTUSURT/********73 10.0.3.78 - - [03/Nov/2016:10:17:09 +0000] "POST /message HTTP/1.1" 303 - 0.0048
2016-11-03T10:17:09Z web:RSVTCTUSURT/********73 there are 3 messages
2016-11-03T10:17:09Z web:RSVTCTUSURT/********73 {"text":"lol","created_at":"2016-11-03T10:17:09+00:00"}
2016-11-03T10:17:09Z web:RSVTCTUSURT/********73 {"text":"bar","created_at":"2016-11-03T10:16:45+00:00"}
2016-11-03T10:17:09Z web:RSVTCTUSURT/********73 {"text":"foo","created_at":"2016-11-03T10:16:38+00:00"}
2016-11-03T10:17:09Z web:RSVTCTUSURT/********73 messages retrieved: [{"text"=>"lol", "created_at"=>"2016-11-03T10:17:09+00:00"}, {"text"=>"bar", "created_at"=>"2016-11-03T10:16:45+00:00"}, {"text"=>"foo", "created_at"=>"2016-11-03T10:16:38+00:00"}]
2016-11-03T10:17:09Z web:RSVTCTUSURT/********73 10.0.3.78 - - [03/Nov/2016:10:17:09 +0000] "GET / HTTP/1.1" 200 1370 0.0056
```

### Others

```
$ convox build
$ convox releases
```

## Credit
Inspired by [convox-archive/sinatra](https://github.com/convox-archive/sinatra)

## License

MIT License

Copyright (c) [2016] [zeroed]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
