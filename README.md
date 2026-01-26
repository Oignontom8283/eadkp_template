
# Eadkp Template

A Rust template for NumWorks app using the EADKP library

## Using

### Method 1 : Distant script


```
bash <(curl -s https://raw.githubusercontent.com/EADKP/eadkp_template/main/bootstrap.sh)>
```
OR
```
bash <(curl -s https://raw.githubusercontent.com/EADKP/eadkp_template/main/bootstrap.sh) --name "my_app">
```

**Finish !**

## Method 2 : Git clone

Clone the repository :
```
git clone https://github.com/Oignontom8283/eadkp_template.git my_app
```

Go to the created folder :
```
cd my_app
```

Run the bootstrap script :
```
chmod +x bootstrap.sh && ./bootstrap.sh
```

**Finish !**

### Method 3 : Cargo generate

You must have cargo-generate and cargo installed !

```
cargo generate --git https://github.com/Oignontom8283/eadkp_template.git --name my_app
```

**Finish !**