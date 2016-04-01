Feature: make command

    Scenario: compile a valid C program using a Makefile
        Given a file named "docker-compose.yml" with:
        """yaml
        make:
          image: arch-docker.eng.lancope.local:5000/c-dev-env:v1.0.0
          volumes:
            - ./:/project
          working_dir: /project
          command: "make"
        """
        And a file named "foo.c" with:
        """
        #include <stdio.h>
        int main() {
            printf("foo\n");
            return 0;
        }
        """
        And a file named "Makefile" with:
        """
        .RECIPEPREFIX = >

        foo: foo.c
        > gcc -o foo foo.c
        """
        When I run `lc make`
        Then it should succeed
        And the file "foo" should be executable

    Scenario: compile an invalid C program using a Makefile
        Given a file named "docker-compose.yml" with:
        """yaml
        make:
          image: arch-docker.eng.lancope.local:5000/c-dev-env:v1.0.0
          volumes:
            - ./:/project
          working_dir: /project
          command: "make"
        """
        And a file named "foo.c" with:
        """
        #include <stdio.h>
        int main() {
            printf("foo\n");XXX
            return 0;
        }
        """
        And a file named "Makefile" with:
        """
        .RECIPEPREFIX = >

        foo: foo.c
        > gcc -o foo foo.c
        """
        When I run `lc make`
        Then it should fail with "error: 'XXX' undeclared"

    Scenario: try to compile without a make service
        Given a file named "docker-compose.yml" with:
        """yaml
        test:
          image: busybox
          command: /bin/true
        """
        And a file named "foo.c" with:
        """
        #include <stdio.h>
        int main() {
            printf("foo\n");XXX
            return 0;
        }
        """
        And a file named "Makefile" with:
        """
        .RECIPEPREFIX = >

        foo: foo.c
        > gcc -o foo foo.c
        """
        When I run `lc make`
        Then it should fail with "No such service: make"

    Scenario: try to compile without a make service, but with template: make
        Given a file named "lc.yml" with:
        """
        template: make
        """
        And a file named "foo.c" with:
        """
        #include <stdio.h>
        int main() {
            printf("foo\n");
            return 0;
        }
        """
        And a file named "Makefile" with:
        """
        .RECIPEPREFIX = >

        foo: foo.c
        > gcc -o foo foo.c
        """
        When I run `lc make`
        Then it should succeed

    Scenario: correct make template
      When I run `lc system view-template make`
      Then it should succeed
      And the output should contain all of these:
        | make:     |
        | test:    |
