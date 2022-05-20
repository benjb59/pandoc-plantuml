## Markdown plantUML converter


```console
foo@bar:~$ ls 
input.md
```

```console
foo@bar:~$ cat input.md
```

````
```plantuml
Bob -> Alice : Hello!
```
````

```console
foo@bar:~$ alias pandoc="docker run -it -v `pwd`:/var/docs melobenja/pandoc-plantuml-mermaid:v0.0.2"
```

```console
foo@bar:~$ pandoc -o output.odt input.md
```

```console
foo@bar:~$ ls
intput.md      output.odt      plantuml-images
```


## Markdown mermaid converter

```console
foo@bar:~$ ls 
input.md
```

```console
foo@bar:~$ cat input.md
```

````
```mermaid
graph TD;
    A-->B;
    A-->C;
    B-->D;
    C-->D;
```
````

```console
foo@bar:~$ alias pandoc="docker run -it -v `pwd`:/var/docs melobenja/pandoc-plantuml-mermaid:v0.0.2"
```

```console
foo@bar:~$ pandoc -o output.odt input.md
```

```console
foo@bar:~$ ls
intput.md      output.odt      mermaid-images
```
