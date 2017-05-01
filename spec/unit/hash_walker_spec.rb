# encoding: utf-8
# frozen_string_literal: true

RSpec.describe TTY::Tree::HashWalker do
  it "walks hash data and collects nodes" do
    data = {
      dir1: [
        'config.dat',
        { dir2: [
          { dir3: [ 'file3-1.txt' ] },
          'file2-1.txt'
          ]
        },
        'file1-1.txt',
        'file1-2.txt'
      ]
    }

    walker = TTY::Tree::HashWalker.new

    walker.traverse(data)

    expect(walker.nodes).to eq([
      TTY::Tree::Node.new('dir1', Pathname.new(''), '', 0),
      TTY::Tree::Node.new('config.dat', Pathname.new('dir1'), '', 1),
      TTY::Tree::Node.new('dir2', Pathname.new('dir1'), '', 1),
      TTY::Tree::Node.new('dir3', Pathname.new('dir1/dir2'), ':pipe', 2),
      TTY::Tree::LeafNode.new('file3-1.txt', Pathname.new('dir1/dir2/dir3'), ':pipe:pipe', 3),
      TTY::Tree::LeafNode.new('file2-1.txt', Pathname.new('dir1/dir2'), ':pipe', 2),
      TTY::Tree::Node.new('file1-1.txt', Pathname.new('dir1'), '', 1),
      TTY::Tree::LeafNode.new('file1-2.txt', Pathname.new('dir1'), '', 1),
    ])

    expect(walker.nodes.map(&:full_path).map(&:to_s)).to eq([
      "dir1",
      "dir1/config.dat",
      "dir1/dir2",
      "dir1/dir2/dir3",
      "dir1/dir2/dir3/file3-1.txt",
      "dir1/dir2/file2-1.txt",
      "dir1/file1-1.txt",
      "dir1/file1-2.txt",
    ])
  end

  it "walks path tree and collects nodes up to max level" do
    data = {
      dir1: [
        'config.dat',
        { dir2: [
          { dir3: [ 'file3-1.txt' ] },
          'file2-1.txt'
          ]
        },
        'file1-1.txt',
        'file1-2.txt'
      ]
    }

    walker = TTY::Tree::HashWalker.new(level: 2)

    walker.traverse(data)

    expect(walker.nodes.map(&:full_path).map(&:to_s)).to eq([
      "dir1",
      "dir1/config.dat",
      "dir1/dir2",
      "dir1/dir2/file2-1.txt",
      "dir1/file1-1.txt",
      "dir1/file1-2.txt",
    ])
  end

  it "counts files & dirs" do
    data = {
      dir1: [
        'config.dat',
        { dir2: [
          { dir3: [ 'file3-1.txt' ] },
          'file2-1.txt'
          ]
        },
        'file1-1.txt',
        'file1-2.txt'
      ]
    }
    walker = TTY::Tree::HashWalker.new

    walker.traverse(data)

    expect(walker.files_count).to eq(5)

    expect(walker.dirs_count).to eq(2)
  end
end
