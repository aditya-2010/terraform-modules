# Terraform Modules

This repository contains a collection of reusable Terraform modules for managing AWS infrastructure. Each module is designed to be easy to integrate into any Terraform project and follows best practices for modular infrastructure-as-code.

## 📁 Repository Structure

```
terraform-modules/
├── modules/
│   ├── vpc/
│   ├── ec2/
│   ├── rds/
│   └── ... (other AWS resources)
├── main.example.tf
└── README.md
```

- **`modules/`**: Contains a folder for each AWS resource, with reusable Terraform configurations.
- **`main.example.tf`**: Demonstrates example usage of the available modules.

## 🚀 Getting Started

To use a module from this repo, you can reference it in your Terraform project like this:

```hcl
module "example_vpc" {
  source = "./modules/vpc"

  # Provide your required input variables here
  cidr_block = "10.0.0.0/16"
  ...
}
```

See the `main.example.tf` file for more usage examples.

## 📦 Available Modules

You can browse the `modules/` folder to see the list of available AWS modules, including:

- VPC
- EC2
- RDS
- (and more...)

Each module has its own set of input variables and outputs, defined in its respective folder.

## 🤝 Contributing

Contributions, improvements, and new modules are welcome! Feel free to open issues or pull requests.
