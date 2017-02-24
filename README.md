Springfield
==========

[![Code Climate](https://codeclimate.com/github/bossiernesto/small_reactor/badges/gpa.svg)](https://codeclimate.com/github/bossiernesto/small_reactor)
[![Stories in Ready](https://badge.waffle.io/bossiernesto/small_reactor.png?label=ready&title=Ready)](https://waffle.io/bossiernesto/small_reactor)
[![Issue Count](https://codeclimate.com/github/bossiernesto/small_reactor/badges/issue_count.svg)](https://codeclimate.com/github/bossiernesto/small_reactor)
[![Build Status](https://travis-ci.org/bossiernesto/springfield.svg?branch=master)](https://travis-ci.org/bossiernesto/springfield)
[![Test Coverage](https://codeclimate.com/github/bossiernesto/small_reactor/badges/coverage.svg)](https://codeclimate.com/github/bossiernesto/small_reactor/coverage)

<img src="https://raw.githubusercontent.com/bossiernesto/springfield/master/Springfield_Nuclear_Power_Plant.png" width="410" height="303">

Small event loop using the reactor pattern. My idea is to have a very simplistic event loop oriented mostly on tcp and ip connections

## Current work

Currently the base event loop is stable and working properly. Unit tests have been created to cover mostly all the code. Some more work 
on keeping the code tested is still needed though. 

The event loop has 

- *Events* that can be simple or IO tasks, these tasks can be timed
- *Timers* are behaviour that can be added to an event and there are different types of timers (quantum, timestamp)
- *Listeners* are blocks that execute a block when an event is attached or detached. 

And soon the event loop will also have

- TCP/IP connections and servers
- Heartbeat
- Failover/Takeover

## Api

Will update with the basic api soon.

