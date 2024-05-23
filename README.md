# Playoffs

[![Gem Version](https://badge.fury.io/rb/playoffs.svg)](https://badge.fury.io/rb/playoffs) [![CI](https://github.com/mattruggio/playoffs/actions/workflows/ci.yaml/badge.svg)](https://github.com/mattruggio/playoffs/actions/workflows/ci.yaml) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

I was looking to create a turn-based sports game which, inevitably, would include a playoffs simulator. This library provides a few, easy-to-use APIs to create, simulate, and complete a team & series-based tournament with one clear winner.

### Installation

To install through Rubygems:

```zsh
gem install playoffs
```

You can also add this to your Gemfile using:

```zsh
bundle add playoffs
```

Copy the executables locally:

```zsh
bundle binstubs playoffs
```

### CLI Usage

This library comes with an executable which shows off the basics of consuming the underlying data structures. It is currently limited to supporting NBA-style playoffs (play-in games included). Let's say we are looking to model the 2024 NBA playoffs, we could run these commands to simulate step-by-step:

#### Create New Tournament

```zsh
bin/playoffs 2024.yaml new BOS,NYK,MIL,CLE,ORL,IND,PHI,MIA,CHI,ATL,OKC,DEN,MIN,LAC,DAL,PHX,LAL,NO,SAC,GS
```

Note(s):

* This will save a serialized tournament to `2024.yaml`
* The last argument is a comma-separated list of teams in ranked order per conference.

### View Bracket

```zsh
bin/playoffs 2024.yaml
```

This will output a tree-based text representation:

```zsh
TBD
└ BestOf::7::Series::TBD::0::TBD::0
  ├ BestOf::7::Series::TBD::0::TBD::0
  │ ├ BestOf::7::Series::TBD::0::TBD::0
  │ │ ├ BestOf::7::Series::BOS::0::TBD::0
  │ │ │ └ BestOf::1::Series::TBD::0::TBD::0
  │ │ │   ├ BestOf::1::Series::PHI::0::MIA::0::LoserAdvances
  │ │ │   └ BestOf::1::Series::CHI::0::ATL::0
  │ │ └ BestOf::7::Series::CLE::0::ORL::0
  │ └ BestOf::7::Series::TBD::0::TBD::0
  │   ├ BestOf::7::Series::MIL::0::IND::0
  │   └ BestOf::7::Series::NYK::0::TBD::0
  │     └ BestOf::1::Series::PHI::0::MIA::0::WinnerAdvances
  └ BestOf::7::Series::TBD::0::TBD::0
    ├ BestOf::7::Series::TBD::0::TBD::0
    │ ├ BestOf::7::Series::OKC::0::TBD::0
    │ │ └ BestOf::1::Series::TBD::0::TBD::0
    │ │   ├ BestOf::1::Series::LAL::0::NO::0::LoserAdvances
    │ │   └ BestOf::1::Series::SAC::0::GS::0::LoserAdvances
    │ └ BestOf::7::Series::LAC::0::DAL::0
    └ BestOf::7::Series::TBD::0::TBD::0
      ├ BestOf::7::Series::MIN::0::PHX::0
      └ BestOf::7::Series::DEN::0::TBD::0
        └ BestOf::1::Series::LAL::0::NO::0::WinnerAdvances
```

### View Rounds

```zsh
bin/playoffs 2024.yaml rounds
```

This will output all series, grouped by round:

```zsh
BestOf::1::Series::PHI::0::MIA::0
BestOf::1::Series::CHI::0::ATL::0
BestOf::1::Series::LAL::0::NO::0
BestOf::1::Series::SAC::0::GS::0

BestOf::1::Series::TBD::0::TBD::0
BestOf::1::Series::PHI::0::MIA::0
BestOf::1::Series::TBD::0::TBD::0
BestOf::1::Series::LAL::0::NO::0

BestOf::7::Series::BOS::0::TBD::0
BestOf::7::Series::CLE::0::ORL::0
BestOf::7::Series::MIL::0::IND::0
BestOf::7::Series::NYK::0::TBD::0
BestOf::7::Series::OKC::0::TBD::0
BestOf::7::Series::LAC::0::DAL::0
BestOf::7::Series::MIN::0::PHX::0
BestOf::7::Series::DEN::0::TBD::0

BestOf::7::Series::TBD::0::TBD::0
BestOf::7::Series::TBD::0::TBD::0
BestOf::7::Series::TBD::0::TBD::0
BestOf::7::Series::TBD::0::TBD::0

BestOf::7::Series::TBD::0::TBD::0
BestOf::7::Series::TBD::0::TBD::0

BestOf::7::Series::TBD::0::TBD::0
```

#### View Up Next

```zsh
bin/playoffs 2024.yaml up
```

This will output the current round number and series (nothing if the tournament is over):

```zsh
1
BestOf::1::Series::PHI::0::MIA::0
```

#### Log a Win

Once you know which series is currently up, use this command to pick a winner:

```zsh
bin/playoffs 2024.yaml win PHI
```

This will output the current series after the win:

```zsh
BestOf::1::Series::PHI::1::MIA::0::Done
```

#### Simulate

The CLI example executable comes with a randomized simulator. This is where this library stops and the application should start: the consumer is responsible to actually deciding winners while this library is only focused on providing the state machine. Run this command to simulate the rest of the games and series:

```zsh
bin/playoffs 2024.yaml sim
```

This will output the number of games simulated and the winner:

```zsh
97
DAL
```

#### View Winner

```zsh
bin/playoffs 2024.yaml winner
```

Will output the winner (nothing if the tournament is not over):

```zsh
DAL
```

### Ruby API Usage

While the CLI executable exemplifies building a consumer app using the data structures provided here, the real power is extending yourself to fit your needs, specifically:

1. Subclassing `Playoffs::Team` to customize per your domain-specific needs
2. Constructing your own tournament using the main `Playoffs::Series` data structure. View `Playoffs::Basketball#tournament_for` to see how an NBA tournament is constructed.
3. Interact with the tournament state machine directly, such as:

   * `Playoffs::Tournament#up_next`: Get the current series which needs a winner.
   * `Playoffs::Series#win`: Log a winner for the current series.
   *  `Playoffs::Tournament#winner`: Get the winning team once there is no current series (series is over).

## Contributing

### Development Environment Configuration

Basic steps to take to get this repository compiling:

1. Install [Ruby](https://www.ruby-lang.org/en/documentation/installation/) (check playoffs.gemspec for versions supported)
2. Install bundler (gem install bundler)
3. Clone the repository (git clone git@github.com:mattruggio/playoffs.git)
4. Navigate to the root folder (cd playoffs)
5. Install dependencies (bundle)

### Running Tests

To execute the test suite run:

```zsh
bin/rspec spec --format documentation
```

Alternatively, you can have Guard watch for changes:

```zsh
bin/guard
```

Also, do not forget to run Rubocop:

```zsh
bin/rubocop
```

And auditing the dependencies:

```zsh
bin/bundler-audit check --update
```

And Sorbet:

```zsh
bin/srb
```

### Publishing

Note: ensure you have proper authorization before trying to publish new versions.

After code changes have successfully gone through the Pull Request review process then the following steps should be followed for publishing new versions:

1. Merge Pull Request into main
2. Update `version.rb` using [semantic versioning](https://semver.org/)
3. Install dependencies: `bundle`
4. Update `CHANGELOG.md` with release notes
5. Commit & push main to remote and ensure CI builds main successfully
6. Run `bin/rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Code of Conduct

Everyone interacting in this codebase, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/mattruggio/playoffs/blob/main/CODE_OF_CONDUCT.md).

## License

This project is MIT Licensed.
