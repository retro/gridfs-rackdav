---
title: GridFS-RackDAV - Mongo GridFS resource for RackDAV
---

## Install

GridFS-RackDAV is hosted at Gemcutter:

    $ sudo gem install gemcutter
    $ sudo gem tumble
    $ sudo gem install gridfs-rackdav

You should also have MongoDB installed.

## Quickstart

Use simple rackup script for serving files from GridFS

    @@ruby

    require 'rubygems'
    require 'rack_dav'
    require 'gridfs-rackdav'
    
    connection = Mongo::Connection.new('localhost').db('name-of-your-db')
     
    use Rack::CommonLogger
     
    run RackDAV::Handler.new({
      :root => 'root_of_collection',
      :connection => connection,
      :resource_class => GridFSRackDAV::GridFSResource
    })

## Specs

GridFS-RackDAV resource passes all of original specs that are included with RackDAV project.

## Copyright

Copyright (c) 2009 Mihael Konjević. See LICENSE for details.
