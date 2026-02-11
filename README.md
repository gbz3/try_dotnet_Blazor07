# try_dotnet_Blazor07

## Codespaces の初期設定

### `git push` 失敗

- 原因: Git LFS が有効なのに git-lfs が入っていないため

```
# 解決策
$ rm -f .git/hooks/pre-push
```

## Blazor アプリ作成

### ソリューションを作成

```
$ dotnet new sln -n BlazorApp07
```

### プロジェクトを作成

```
$ dotnet new blazor -n BlazorApp07 \
  --framework net8.0 \
  --auth None \
  --interactivity Server
The template "Blazor Web App" was created successfully.

# ソリューションに追加
$ dotnet sln BlazorApp07.sln add BlazorApp07/BlazorApp07.csproj
Project `BlazorApp07/BlazorApp07.csproj` added to the solution.
$
```

### NuGet パッケージを追加

```bash
dotnet add BlazorApp07 package Microsoft.EntityFrameworkCore --version 8.*
dotnet add BlazorApp07 package Microsoft.EntityFrameworkCore.SqlServer --version 8.*
dotnet add BlazorApp07 package Microsoft.AspNetCore.Components.QuickGrid
```
