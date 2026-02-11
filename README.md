# try_dotnet_Blazor07

## Codespaces の初期設定

### `git push` 失敗

- 原因: Git LFS が有効なのに git-lfs が入っていないため

```
# 解決策
$ rm -f .git/hooks/pre-push
```
