#!/usr/bin/perl -w
use strict;

use lib "lib";
use AnyEvent::Discord::Client;

die "usage: $0 token" unless @ARGV;
my $token = $ARGV[0];

my %commands_hidden = map{$_=>1} qw(setstatus);

my $bot = new AnyEvent::Discord::Client(
  token => $token,
  commands => {
    'commands' => sub {
      my ($bot, $args, $msg, $channel, $guild) = @_;
      $bot->say($channel->{id}, join("   ", map {"`$_`"} sort grep {!$commands_hidden{$_}} keys %{$bot->commands}));
    },
  },
);

$bot->add_commands(
  'setstatus' => sub {
    my ($bot, $args, $msg, $channel, $guild) = @_;
    return unless $msg->{author}{id} == $guild->{owner_id};

    # send "status update" op
    $bot->websocket_send(3, {
        since => undef,
        game => {
          name => $args,
          type => 0
        },
        status => "online",
        afk => "false"
    });
  },
  'hello' => sub {
    my ($bot, $args, $msg, $channel, $guild) = @_;

    $bot->say($channel->{id}, "hi, $msg->{author}{username}!");
  },
);

$bot->connect();
AnyEvent->condvar->recv;
