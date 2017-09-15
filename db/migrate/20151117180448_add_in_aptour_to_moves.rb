class AddInAptourToMoves < ActiveRecord::Migration
  def change
    add_column :moves, :in_aptour, :boolean, default: false
  end
end
