# Xee
[![Build Status](https://travis-ci.org/xeejp/xee.svg?branch=master)](https://travis-ci.org/xeejp/xee)

# Instalation(for Windows users)

---

## 1. Elixir 1.4 or later
Download [Elixir](https://elixir-lang.org/) from [Elixir-Install](https://elixir-lang.org/install.html) page, and install it.  
The latest version of Elixir is now 1.6.5.  
And install Erlang/OTP by Elixir installer. The latest version of Erlang OTP is now 20.2.  
We recommend to use default settings of installer.  

## 2. Phoenix
Download Phoenix Framework via mix command.
Run command prompt application (type `cmd` into your desktop search bar) and type like follows:
```
mix archive.install https://github.com/phoenixframework/archives/raw/master/phoenix_new-1.2.5.ez
```
Then press "Y".
The latest version of Phoenix Framework is 1.3.2, but we use 1.2.5.

## 3. Node.js
Visit [Node.js](https://nodejs.org/en/) site and download "LTS version" installer.
Please note that "current version" is not supported.

### 4. Visual Studio
Visit [Visual Studio Download Page](https://www.visualstudio.com/downloads/) and download "Visual Studio Community 2017" because it's free.
Install "C++によるデスクトップ開発" from top page and "Git for Windows" from "個別のコンポーネント".
Make sure that "vcvrsall.bat" has been installed under the "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build".
After you install these, run Visual Studio and open new project at once.

## 4. Postgre SQL
Visit [Postgre SQL](https://www.postgresql.org/) and [Download Page](https://www.postgresql.org/download/), then download Installer.
Then download "PostgreSQL 10.4" and "Windows x86-64" version.
Use "postgres" as Password.
After you install PostgreSQL, ignore "Stack Builder".

## 5. Yarn
Download [Yarn](https://yarnpkg.com/lang/en/) from [Download](https://yarnpkg.com/en/docs/install#windows-stable) page.

## 6. Xee
Type:
```
git clone https://github.com/xeejp/xee.git
npm install webpack@^1.15.0 -g
cd xee
mix deps.get
cmd /K "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvarsall.bat" amd64
mix deps.compile
```

  ### 6.1. Setting Database
  Set up the database as follows:
  ```
  mix ecto.create
  mix ecto.migrate
  ```

  ### 6.2. Webpack
  Run `npm install`
  If you see any error or warning, don't care and ignore it.
  And run `webpack`

  ### 6.3. Check default
  Run
  `mix phoenix.server`
  and you can see your XEE local web site on [http://localhost:4000](http://localhost:4000).
  If you couldn't see "Master XEE", webpack may be failed.
  Check database connection using user registry system.
  Visit "教師用画面" and try to make register some user.
  If some error occuerd, it may casued by postgreSQL or `ecto`.

## 7. Add Theme Module (for example)
  ### 7.1. Webpack
  ```
  cd apps\
  git clone https://github.com/xeejp/xee_linda_problem_simple.git
  cd xee_linda_problem_simple
  mix deps.get
  yarn install
  yarn add webpack@^1.15
  yarn add babel-core babel-loader babel-preset-es2015 babel-preset-react --dev
  yarn run webpack
  ```

  ### 7.2. Config file settings
  Change directory to "xee/config/", and modify "theme.exs."
  ```
  theme LindaProblemSimple,
   name: "リンダ問題",
   path: "apps/xee_linda_problem_simple",
   host: "host.js",
   participant: "participant.js",
   tags: ["相互作用なし"]
 ```

### 7.3. Run Xee
Change directory to "xee" and `mix phoenix.server`, then you can use new theme.

## 8. For your convenience.
 ### 8.1. Use supervisor mode
 You can use supervisor mode form your teachers page.
 If URI of teachers page is like `http://localhost:4000/experiment/ABC/host`,
 visit `http://localhost:4000/experiment/ABC/host/X` as user "X".
