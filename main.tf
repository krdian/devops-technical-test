data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  filter {
   name = "name"
   values = ["ubuntu-*-server-*"]
  }

}
resource "aws_key_pair" "auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"

}

resource "aws_instance" "es_node_01" {
    ami = "${data.aws_ami.ubuntu.id}"
    instance_type = "t2.micro"
    tags {
        Name = "ElasticSearchNode01"
    }
    subnet_id = "${aws_subnet.default.id}"
    key_name = "${aws_key_pair.auth.id}"
    vpc_security_group_ids = ["${aws_security_group.default.id}"]

    provisioner "remote-exec" {
        inline = [
                "sudo apt-get -y update",
                "sudo apt-get -y install nginx",
                "sudo service nginx start",
                "sudo apt-get -y install openjdk-7-jre",
                "wget https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-1.7.2.deb",
                "sudo dpkg -i elasticsearch-1.7.2.deb",
                "sudo update-rc.d elasticsearch defaults",
                "sudo service elasticsearch start"
        ]

    }


    connection {
    	user = "ubuntu"

    	#agent = true
    	type = "ssh"
    	#key_file = "${var.key_path}"
    	#private_key = "${var.key_path}"
    	private_key = "${file("${var.key_path}")}"
  }

}

resource "aws_instance" "es_node_02" {
    ami = "${data.aws_ami.ubuntu.id}"
    instance_type = "t2.micro"
    tags {
        Name = "ElasticSearchNode02"
    }
    subnet_id = "${aws_subnet.default.id}"
    key_name = "${aws_key_pair.auth.id}"

    vpc_security_group_ids = ["${aws_security_group.default.id}"]

    provisioner "remote-exec" {
        inline = [
                "sudo apt-get -y update",
                "sudo apt-get -y install nginx",
                "sudo service nginx start",
                "sudo apt-get -y install openjdk-7-jre",
                "wget https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-1.7.2.deb",
                "sudo dpkg -i elasticsearch-1.7.2.deb",
                "sudo update-rc.d elasticsearch defaults",
                "sudo service elasticsearch start"
        ]

    }
         connection {
    user = "ubuntu"

    #agent = true
    type = "ssh"
    private_key = "${file("${var.key_path}")}"
  }
}

resource "aws_instance" "es_node_02" {
    ami = "${data.aws_ami.ubuntu.id}"
    instance_type = "t2.micro"
    tags {
        Name = "ElasticSearchNode03"
    }
    subnet_id = "${aws_subnet.default.id}"
    key_name = "${aws_key_pair.auth.id}"

    vpc_security_group_ids = ["${aws_security_group.default.id}"]

    provisioner "remote-exec" {
        inline = [
                "sudo apt-get -y update",
                "sudo apt-get -y install nginx",
                "sudo service nginx start",
                "sudo apt-get -y install openjdk-7-jre",
                "wget https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-1.7.2.deb",
                "sudo dpkg -i elasticsearch-1.7.2.deb",
                "sudo update-rc.d elasticsearch defaults",
                "sudo service elasticsearch start"
        ]

    }
         connection {
    user = "ubuntu"

    #agent = true
    type = "ssh"
    private_key = "${file("${var.key_path}")}"
  }
}

resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

resource "aws_subnet" "default" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

# Load Balancer
resource "aws_elb" "elasticsearch" {
  name = "test-es"

  subnets         = ["${aws_subnet.default.id}"]
  security_groups = ["${aws_security_group.default.id}"]
  instances       = ["${aws_instance.es_node_01.id}","${aws_instance.es_node_02.id}","${aws_instance.es_node_03.id}"]

  listener {
    instance_port     = 9200
    instance_protocol = "http"
    lb_port           = 9200
    lb_protocol       = "http"
  }
}


# Acces to  port 9200 from an internal network
resource "aws_security_group" "default" {
  name        = "es_test"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

