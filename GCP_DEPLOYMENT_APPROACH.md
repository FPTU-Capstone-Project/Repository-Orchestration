# GCP Deployment Architecture - Best Approach Proposals

## 📋 Yêu Cầu
- Provision backend API + PostgreSQL DB trên GCP
- Deploy workflow giống AWS: merge main → build Docker → push DockerHub → terraform deploy
- External connections (RabbitMQ, Redis, Cloudinary...) hoạt động tốt từ GCP VM
- Scripts: deploy và test connectivity tương tự AWS

---

## 🎯 3 APPROACHES - So Sánh Chi Tiết

### ✅ **APPROACH 1: SEPARATE PROJECT (RECOMMENDED)**
**Tạo project terraform-gcp hoàn toàn riêng biệt**

#### 📁 Cấu Trúc Thư Mục
```
Orchestration-Server&Client/
├── terraform-aws/          # Giữ nguyên, không đụng
│   ├── main.tf
│   ├── variables.tf
│   ├── deploy-by-pulling-latest-images.sh
│   └── test-external-connections.sh
│
├── terraform-gcp/          # MỚI - Project riêng cho GCP
│   ├── main.tf             # GCP provider, GCE instance, Cloud SQL
│   ├── variables.tf        # GCP-specific variables
│   ├── outputs.tf
│   ├── terraform.tfvars
│   ├── startup-script.sh   # Tương tự user-data.sh của AWS
│   ├── deploy-by-pulling-latest-images.sh
│   ├── test-external-connections.sh
│   └── README.md
│
└── backend/                # Backend code không đổi
```

#### ✅ **Ưu Điểm**
- **ZERO RISK**: Không ảnh hưởng infra AWS hiện tại
- **Độc lập hoàn toàn**: Mỗi cloud có state, config riêng
- **Dễ maintain**: Clear separation of concerns
- **Safe testing**: Test GCP không lo break AWS
- **CI/CD đơn giản**: Deploy AWS và GCP độc lập
- **Rollback dễ**: Có vấn đề GCP → xóa folder, AWS vẫn ngon

#### ⚠️ **Nhược Điểm**
- Duplicate code (variables, scripts tương tự)
- Phải maintain 2 projects
- Nếu thay đổi logic chung → update 2 nơi

#### 🛠️ **Implementation Steps**
```bash
# 1. Tạo project mới
mkdir terraform-gcp
cd terraform-gcp

# 2. Copy structure từ terraform-aws làm template
cp -r ../terraform-aws/variables.tf .
cp -r ../terraform-aws/outputs.tf .

# 3. Modify cho GCP
# - Replace AWS provider → GCP provider
# - EC2 → Compute Engine
# - RDS → Cloud SQL (hoặc PostgreSQL on VM như AWS)

# 4. Test riêng
terraform init
terraform plan
terraform apply

# 5. Scripts deploy và test
./deploy-by-pulling-latest-images.sh  # SSH to GCP VM
./test-external-connections.sh         # Test từ GCP VM
```

---

### 🔶 **APPROACH 2: MULTI-PROVIDER IN ONE PROJECT**
**Dùng chung 1 project terraform với nhiều providers**

#### 📁 Cấu Trúc Thư Mục
```
Orchestration-Server&Client/
└── terraform-multi-cloud/  # RENAME terraform-aws
    ├── main-aws.tf         # AWS resources
    ├── main-gcp.tf         # GCP resources
    ├── variables-aws.tf
    ├── variables-gcp.tf
    ├── outputs.tf
    ├── terraform.tfvars    # Chứa config cho cả AWS & GCP
    ├── scripts/
    │   ├── aws/
    │   │   ├── deploy.sh
    │   │   └── test-connections.sh
    │   └── gcp/
    │       ├── deploy.sh
    │       └── test-connections.sh
    └── README.md
```

#### ✅ **Ưu Điểm**
- Share common variables dễ dàng
- Một terraform state (nếu dùng remote backend)
- Nhìn tổng quan cả 2 clouds trong 1 chỗ
- Có thể dùng outputs từ AWS làm inputs cho GCP (nếu cần)

#### ⚠️ **Nhược Điểm**
- **RỦI RO CAO**: `terraform apply` có thể vô tình apply cả AWS
- State phức tạp: Lỗi GCP có thể lock cả AWS state
- Khó rollback từng cloud riêng
- Provider conflicts có thể xảy ra
- Testing khó: Không thể test GCP mà không load AWS config

#### 🛠️ **Implementation Steps**
```bash
# 1. Backup terraform-aws hiện tại
cp -r terraform-aws terraform-aws-backup

# 2. Rename và restructure
mv terraform-aws terraform-multi-cloud

# 3. Split main.tf
mv main.tf main-aws.tf
touch main-gcp.tf

# 4. Add GCP provider
# main-gcp.tf
provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# 5. Deploy riêng từng cloud với target
terraform apply -target=aws_instance.backend  # Chỉ AWS
terraform apply -target=google_compute_instance.backend  # Chỉ GCP
```

---

### 🔷 **APPROACH 3: TERRAFORM WORKSPACES**
**Dùng workspaces để tách môi trường AWS/GCP**

#### 📁 Cấu Trúc Thư Mục
```
Orchestration-Server&Client/
└── terraform-backend/
    ├── main.tf             # Contains logic cho cả AWS & GCP
    ├── variables.tf        # Generic variables
    ├── outputs.tf
    ├── terraform.tfvars.aws
    ├── terraform.tfvars.gcp
    └── README.md

# Workspaces
# - default (không dùng)
# - aws-prod
# - gcp-prod
```

#### ✅ **Ưu Điểm**
- Same codebase cho nhiều clouds
- Switch giữa clouds dễ: `terraform workspace select gcp-prod`
- DRY principle: Không duplicate code

#### ⚠️ **Nhược Điểm**
- **KHÔNG PHÙ HỢP** cho multi-cloud khác nhau (AWS vs GCP)
- Workspaces thiết kế cho CÙNG INFRA, KHÁC ENVIRONMENT (dev/staging/prod)
- Code phức tạp: Phải handle logic cho cả 2 clouds trong 1 file
- Khó maintain: If-else statements cho AWS/GCP logic

#### ❌ **Kết Luận**: KHÔNG KHUYẾN NGHỊ cho use case này

---

## 🏆 RECOMMENDATION: APPROACH 1 - SEPARATE PROJECT

### 📊 Lý Do Chọn Approach 1

| Tiêu Chí | Approach 1 | Approach 2 | Approach 3 |
|----------|------------|------------|------------|
| **Safety** | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ |
| **Maintainability** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ |
| **Isolation** | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐ |
| **CI/CD** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| **Debugging** | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐ |
| **Rollback** | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ |

### 🎯 Chi Tiết Implementation - Approach 1

#### Step 1: Project Structure
```bash
cd /Users/khoa123/Desktop/Orchestration-Server\&Client

# Tạo terraform-gcp
mkdir terraform-gcp
cd terraform-gcp

# Initialize Git để track riêng (nếu cần)
git checkout -b feature/add-gcp-deployment
```

#### Step 2: Core Files

**terraform-gcp/main.tf**
```hcl
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
  credentials = file(var.gcp_credentials_file)
}

# Compute Engine instance (tương tự EC2)
resource "google_compute_instance" "backend" {
  name         = "${var.project_name}-backend-${var.environment}"
  machine_type = var.machine_type
  zone         = var.gcp_zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = var.disk_size
      type  = "pd-standard"
    }
  }

  network_interface {
    network = "default"
    access_config {
      # Ephemeral public IP
    }
  }

  metadata_startup_script = templatefile("${path.module}/startup-script.sh", {
    docker_image = var.docker_image
    # ... other variables
  })

  tags = ["backend-server", "http-server", "https-server"]
}

# Cloud SQL cho PostgreSQL (HOẶC install trên VM như AWS)
# Option 1: PostgreSQL on VM (giống AWS) - CHEAPER
# Option 2: Cloud SQL - MANAGED
```

**terraform-gcp/variables.tf**
```hcl
variable "gcp_project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "gcp_region" {
  description = "GCP Region"
  type        = string
  default     = "asia-southeast1"  # Singapore
}

variable "machine_type" {
  description = "GCE machine type"
  type        = string
  default     = "e2-micro"  # Free tier
}

# ... rest similar to AWS variables
```

#### Step 3: Deployment Scripts

**terraform-gcp/deploy-by-pulling-latest-images.sh**
```bash
#!/bin/bash
# Giống AWS nhưng SSH vào GCP VM

echo "🚀 Deploying to GCP Compute Engine..."

GCP_IP=$(terraform output -raw instance_public_ip)
SSH_KEY="./ssh-key-motorbike-gcp"

ssh -i $SSH_KEY ubuntu@$GCP_IP << 'EOF'
echo "⏹️  Stopping old container..."
docker stop motorbike-backend 2>/dev/null || true

echo "📥 Pulling latest image..."
docker pull khoatdse172986/motorbike-backend:latest

echo "🚀 Starting new container..."
docker run -d \
  --name motorbike-backend \
  --restart unless-stopped \
  --network host \
  -e SPRING_DATASOURCE_URL='jdbc:postgresql://localhost:5432/motorbike_sharing' \
  # ... same env vars as AWS
  khoatdse172986/motorbike-backend:latest

echo "✅ Container started!"
EOF
```

**terraform-gcp/test-external-connections.sh**
```bash
#!/bin/bash
# Copy từ AWS version, chỉ đổi IP và SSH key

GCP_IP=$(terraform output -raw instance_public_ip)
SSH_KEY="./ssh-key-motorbike-gcp"

# Test RabbitMQ
ssh -i $SSH_KEY ubuntu@$GCP_IP "curl -v telnet://$RABBITMQ_HOST:$RABBITMQ_PORT"

# Test Redis
ssh -i $SSH_KEY ubuntu@$GCP_IP "redis-cli -h $REDIS_HOST -p $REDIS_PORT --tls ping"

# ... other tests
```

#### Step 4: CI/CD Workflow

**Deploy Workflow Giống AWS**
```bash
# 1. Backend merge to main
cd backend
git add .
git commit -m "feat: new feature"
git push origin main

# 2. Build Docker image (có thể automate với GitHub Actions)
docker build -t khoatdse172986/motorbike-backend:latest .
docker push khoatdse172986/motorbike-backend:latest

# 3. Deploy to GCP
cd ../terraform-gcp
./deploy-by-pulling-latest-images.sh

# 4. Test connections
./test-external-connections.sh

# AWS deployment vẫn giữ nguyên
cd ../terraform-aws
./deploy-by-pulling-latest-images.sh
```

---

## 🔐 Security & Best Practices

### 1. Separate State Files
```hcl
# terraform-aws/main.tf
terraform {
  backend "s3" {
    bucket = "motorbike-terraform-state-aws"
    key    = "aws/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

# terraform-gcp/main.tf
terraform {
  backend "gcs" {
    bucket = "motorbike-terraform-state-gcp"
    prefix = "gcp/terraform.tfstate"
  }
}
```

### 2. Separate Secrets
```bash
# terraform-aws/.env
AWS_ACCESS_KEY_ID=xxx
AWS_SECRET_ACCESS_KEY=xxx

# terraform-gcp/.env
GOOGLE_APPLICATION_CREDENTIALS=./gcp-service-account.json
```

### 3. Firewall Rules
```hcl
# GCP Firewall giống AWS Security Group
resource "google_compute_firewall" "backend" {
  name    = "${var.project_name}-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "8080"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["backend-server"]
}
```

---

## 📦 Cost Comparison

| Resource | AWS (Current) | GCP (Proposed) |
|----------|---------------|----------------|
| **VM** | t2.micro (1GB RAM) | e2-micro (1GB RAM) |
| **Price** | $8.5/month | Free tier 744h/month |
| **DB** | PostgreSQL on VM | PostgreSQL on VM |
| **Storage** | 20GB gp3 | 30GB pd-standard (free tier) |
| **Network** | 1GB free/month | 1GB free/month (NA→Worldwide) |
| **Total** | ~$10/month | **$0-5/month** (if within free tier) |

---

## 🚀 Migration Steps (Tuần Tự)

### Phase 1: Setup (Week 1)
- [ ] Tạo GCP project
- [ ] Tạo folder `terraform-gcp`
- [ ] Copy & modify files từ `terraform-aws`
- [ ] Setup GCP service account & credentials

### Phase 2: Test Infrastructure (Week 1-2)
- [ ] `terraform init` & `terraform plan`
- [ ] `terraform apply` (provision GCP VM + DB)
- [ ] Test SSH connection
- [ ] Test external connections (RabbitMQ, Redis...)

### Phase 3: Deployment (Week 2)
- [ ] Create `deploy-by-pulling-latest-images.sh`
- [ ] Test manual deployment
- [ ] Verify backend API hoạt động
- [ ] Test all endpoints

### Phase 4: Automation (Week 3)
- [ ] GitHub Actions cho GCP deployment
- [ ] Monitoring & alerting
- [ ] Documentation

---

## ⚠️ Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Vô tình chạy terraform apply ở AWS | **Separate folders**, check `pwd` trước khi apply |
| GCP quota limits | Check free tier limits, set billing alerts |
| External connections fail | Test script BEFORE production deployment |
| State file conflicts | Use remote backends (S3 for AWS, GCS for GCP) |
| Downtime during deployment | Blue-green deployment or use Load Balancer |

---

## 📚 Next Steps

1. **Approve Approach 1** ✅
2. **Create terraform-gcp folder**
3. **I will help you write all GCP terraform files**
4. **Test deployment step by step**
5. **Update CI/CD if needed**

---

## 🤔 Questions to Clarify

1. **PostgreSQL**: On VM (như AWS) hay dùng Cloud SQL managed?
   - On VM: Rẻ hơn, giống AWS
   - Cloud SQL: Managed, auto backup, HA (đắt hơn)

2. **Budget**: Free tier only hay có budget cho VM lớn hơn?

3. **Networking**: Có cần VPC riêng hay dùng default VPC?

4. **CI/CD**: Deploy manual hay setup GitHub Actions?

---

**Sẵn sàng implement khi bạn approve approach! 🚀**
