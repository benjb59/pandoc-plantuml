```console
foo@bar:~$ ls 
input.md

foo@bar:~$ cat input.md
````
```plantuml
Bob -> Alice : Hello!
```
````
```

```console
foo@bar:~$ alias pandoc="docker run -it -v `pwd`:/var/docs melobenja/pandoc-plantuml-mermaid:v0.0.2"

foo@bar:~$ pandoc -i input.md -o output.odt

foo@bar:~$ ls
output.odt      plantuml-images
```
