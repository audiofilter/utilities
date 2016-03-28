#!/usr/bin/perl
#
# spotprices
#
# Copyright (C) 2008
# Paul E. Jones <paulej@packetizer.com>
#
# This program will connect to Packetizer's Precious Metal Spot Prices Service
# and display the current spot prices.
#
# The XML returned by the server is in this form:
#
#    <?xml version="1.0" encoding="UTF-8"?>
#    <SpotPrices>
#        <date>2008-05-29</gold>
#        <gold>877.80</gold>
#        <silver>16.62</silver>
#        <platinum>2006.00</platinum>
#    </SpotPrices>
#
# We implement a small state machine to ensure that we grab the right node,
# should the XML schema change in the future.
#
#

use LWP;
use XML::Parser;

# Define the state transition table for the XML file to be processed.
#
# The state transition table exists to help us collect only the data
# we're interested in.  If we're processing a large XML file and only
# want one element, parsing and storing everything in memory is a waste.
#
# If you did want to grab everything, this would do it:
#
# %xml_state_machine =
# (
# #   Current State          Element Found         New State
#     __IDLE__        => {
#                            __DEFAULT__        => "__TARGET__"
#                        },
#     __TARGET__      => {
#                            __DEFAULT__        => "__TARGET__"
#                        }
# );
#
# If you only want to grab three elements, e.g., gold, silver, platinum,
# and all elements defined within those, you could create this simple
# state transition table.  All other elements (e.g., date) would be
# skipped over:
#
# %xml_state_machine =
# (
# #   Current State          Element Found         New State
#     __IDLE__        => {
#                            SpotPrices         => "SPOT_PRICES",
#                            __DEFAULT__        => "__NON_TARGET__"
#                        },
#     __NON_TARGET__  => {
#                            __DEFAULT__        => "__NON_TARGET__"
#                        },
#     SPOT_PRICES     => {
#                            gold               => "__TARGET__",
#                            silver             => "__TARGET__",
#                            platinum           => "__TARGET__",
#                            __DEFAULT__        => "__NON_TARGET__"
#                        },
#     __TARGET__      => {
#                            __DEFAULT__        => "__TARGET__"
#                        }
# );
#
# For the purposes of demonstration, we'll use a more verbose state
# table.  This will grab only the elements gold, silver, and platinum
# and would skip any and all child elements of those three elements:
#
%xml_state_machine =
(
#   Current State          Element Found         New State
    __IDLE__        => {
                           SpotPrices         => "SPOT_PRICES",
                           __DEFAULT__        => "__NON_TARGET__"
                       },
    __NON_TARGET__  => {
                           __DEFAULT__        => "__NON_TARGET__"
                       },
    SPOT_PRICES     => {
                           gold               => "GOLD",
                           silver             => "SILVER",
                           platinum           => "PLATINUM",
                           __DEFAULT__        => "__NON_TARGET__"
                       },
    GOLD            => {
                           __DEFAULT__        => "__NON_TARGET__"
                       },
    SILVER          => {
                           __DEFAULT__        => "__NON_TARGET__"
                       },
    PLATINUM        => {
                           __DEFAULT__        => "__NON_TARGET__"
                       }
);

# Initialize the XML parsing state machine
sub init_handler
{
    $xml_parsing_state = "__IDLE__";
    $xml_tree_name = "";
    @xml_parsing_stack = ();
    %xml_character_data = {};
    %xml_element_attrs = {};
}

# XML Parsing call-back routines
sub start_handler
{
    my($expat, $element, %attrs) = @_;
    my $next_state;

    # Store the previous parsing state on the stack
    push(@xml_parsing_stack, $xml_parsing_state);
    push(@xml_parsing_stack, $xml_tree_name);

    # Advance the state machine
    $next_state = $xml_state_machine{$xml_parsing_state}{$element};

    # If the next state is unknown, then we move to the default state "*"
    if (length($next_state) == 0)
    {
        $next_state = $xml_state_machine{$xml_parsing_state}{"__DEFAULT__"};
        if (length($next_state) == 0)
        {
            die "Error: no default transition for state $xml_parsing_state";
        }
    }

    # Advance the parsing state
    $xml_parsing_state = $next_state;

    # Update the tree name
    $xml_tree_name .= "/$element";

    # Clear character data associated with this state. (This is 
    # necessary if elements appear multiple times in a file, in which
    # case, character data needs to be collected in end_handler.)
    # Also store any attributes found in a hash.
    if ($xml_parsing_state ne "__NON_TARGET__")
    {
        $xml_character_data{$xml_tree_name} = "";
        $xml_element_attrs{$xml_tree_name} = {};

        # Store each attribute found
        while((my $key, my $value) = each(%attrs))
        {
            $xml_element_attrs{$xml_tree_name}{$key} = $value;
        }
    }
}

sub char_handler
{
    my ($expat, $chardata) = @_;

    if ($xml_parsing_state ne "__NON_TARGET__")
    {
        $xml_character_data{$xml_tree_name} .= $chardata;
    }
}

sub end_handler
{
    my ($expat, $element) = @_;

    # In general, character data within an element should be stripped
    # of leading and trailing whitespace.  If you prefer to keep it,
    # then comment out these lines
    $xml_character_data{$xml_tree_name} =~ s/^[ \t\n\r\f]*//;
    $xml_character_data{$xml_tree_name} =~ s/[ \t\n\r\f]*$//;

    # Since we've reached the end of an element, lets move back to the
    # previous parsing state.
    $xml_tree_name = pop(@xml_parsing_stack);
    $xml_parsing_state = pop(@xml_parsing_stack);
}

#
# MAIN
#
{
    # Service URL
    $url = "http://services.packetizer.com/spotprices/";

    # Define a user agent
    $ua = LWP::UserAgent->new;

    # Get the page from the server
    $response = $ua->get($url, "Accept" => "application/xml");

    die "Error: Unable to get spot prices: " . $response->status_line . "\n"
        unless $response->is_success;

    die "Error: Invalid content type: " . $response->content_type . "\n"
        unless $response->content_type eq "application/xml";

    # Parse the XML message
    $parser = XML::Parser->new(ErrorContext => 2);
    $parser->setHandlers(Init  => \&init_handler,
                         Start => \&start_handler,
                         End   => \&end_handler,
                         Char  => \&char_handler);

    eval { $parser->parse($response->content); };
    if ($@)
    {
       die "There was an error parsing the XML:\n$@\n";
    }

    # Produce the spot prices
    print "GLD \$" . $xml_character_data{'/SpotPrices/gold'} ."\n";
}
