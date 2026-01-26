
# Eadkp Template

A Rust template for NumWorks apps using the EADKP library.

## Usage

### Method 1: Remote Script

Run the following command:

```
bash <(curl -s https://raw.githubusercontent.com/EADKP/eadkp_template/main/bootstrap.sh)>
```
OR
```
bash <(curl -s https://raw.githubusercontent.com/EADKP/eadkp_template/main/bootstrap.sh) --name "my_app">
```

**Finish !**

## Method 2 : Git clone

Clone the repository:
```
git clone https://github.com/Oignontom8283/eadkp_template.git my_app
```

Navigate to the created folder:
```
cd my_app
```

Run the bootstrap script:
```
chmod +x bootstrap.sh && ./bootstrap.sh
```

**Finish !**

### Method 3 : Cargo generate

Ensure you have `cargo-generate` and `cargo` installed.

Run the following command:
```
cargo generate --git https://github.com/Oignontom8283/eadkp_template.git --name my_app
```

**Finish !**

## Features

- EADKP integration
- Preconfigured `Cargo.toml`
- Preconfigured `.cargo/config.toml`
- Preconfigured `justfile`
- Preconfigured `docker-compose.yml`*
- Preconfigured build scripts
- Example code
- `.gitignore` file
- Bootstrap script for quick project setup
- Ready to build and flash on NumWorks calculators

## Requirements

- `curl`
- `git`
- `docker`

## License

This template is licensed under GPL-v3.0. See the [LICENSE](./LICENSE) file for more details.

The GPL-v3.0 license applies only to the template's code. The code you write for your application is not affected by this license, and you are free to license it as you wish. However, the EADKP library used in this template is licensed under GPL-v3.0, so you must comply with the terms of this license when using the EADKP library in your application.

## Contributions

Feel free to suggest improvements or fixes via pull requests or issues!