# Symfony Commands

---

## Built-in Commands (1/2)

    !bash
    $ php bin/console


### Global Options

You can get **help** information:

    !bash
    $ php bin/console help cmd
    $ php bin/console cmd --help
    $ php bin/console cmd -h

You can get more verbose messages:

    !bash
    $ php bin/console cmd --verbose
    $ php bin/console cmd -v [-vv] [-vvv]

You can suppress output:

    !bash
    $ php bin/console cmd --quiet
    $ php bin/console cmd -q

---

## Built-in Commands (2/2)

    !text
    assets
      assets:install          Installs bundles web assets under a public

    cache
      cache:clear             Clears the cache
      cache:warmup            Warms up an empty cache

    config
      config:dump-reference   Dumps default configuration for an extension

    debug
      debug:container         Displays current services for an application
      debug:event-dispatcher  Displays configured listeners for an application
      debug:router            Displays current routes for an application
                              web directory
      debug:twig              Shows a list of twig functions, filters, […]

    router
      router:match            Helps debug routes by simulating a path info match

    server
      server:run              Runs PHP built-in web server

    lint
      lint:twig               Lints a template and outputs encountered
                              errors

---

## Creating Commands

Create a `Command` directory inside your bundle and create a php file suffixed
with `Command.php` for each command that you want to provide:

    !php
    // src/AppBundle/Command/GreetCommand.php
    namespace AppBundle\Command;

    use Symfony\Bundle\FrameworkBundle\Command\ContainerAwareCommand;
    use Symfony\Component\Console\Input\InputInterface;
    use Symfony\Component\Console\Output\OutputInterface;

    class GreetCommand extends ContainerAwareCommand
    {
        protected function configure()
        {
            $this->setName('demo:greet');
        }

        protected function execute(InputInterface $input, OutputInterface $output)
        {
            // code ...
        }
    }

---

## Command Arguments

**Arguments** are the strings, separated by spaces, that come after the command
name itself. They are ordered, and can be **optional** or **required**.

    !php
    protected function configure()
    {
        $this
            // ...
            ->addArgument(
                'name', InputArgument::REQUIRED, 'Who do you want to greet?'
            )
            ->addArgument(
                'last_name', InputArgument::OPTIONAL, 'Your last name?'
            );
    }

### Usage

    !php
    // php bin/console demo:greet Kévin Gomez
    $input->getArgument('last_name');

---

## Command Options (1/2)

Unlike arguments, **options are not ordered**, **always optional**, and can be
setup to accept a value or simply as a boolean flag without a value.

    !php
    protected function configure()
    {
        $this
            // ...
            ->addOption(
                'yell', null, InputOption::VALUE_NONE,
                'If set, the task will yell in uppercase letters'
            );
    }

### Usage

    !php
    // php bin/console demo:greet --yell

    if ($input->getOption('yell')) {
        // ...
    }

---

## Command Options (2/2)

    !php
    protected function configure()
    {
        $this
            // ...
            ->addOption(
                'iterations', null, InputOption::VALUE_REQUIRED,
                'How many times should the message be printed?',
                1
            );
    }

### Usage

    !php
    // php bin/console demo:greet --iterations=10

    for ($i = 0; $i < $input->getOption('iterations'); $i++) {
    }

---

## More On Commands

### Getting Services from the Service Container

    !php
    protected function execute(InputInterface $input, OutputInterface $output)
    {
        $translator = $this->getContainer()->get('translator');
        // ...
    }

### Calling an existing Command

    !php
    $command = $this->getApplication()->find('demo:greet');
    $arguments = [
        'command' => 'demo:greet',
        'name'    => 'Fabien',
        'yell'    => true,
    ];

    $returnCode = $command->run(new ArrayInput($arguments), $output);

> [http://symfony.com/doc/master/cookbook/console/index.html](http://symfony.com/doc/master/cookbook/console/index.html)
