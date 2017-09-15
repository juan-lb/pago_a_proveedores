class CreateServiceRegisters < ActiveRecord::Migration
  def change
    create_table :service_registers do |t|
      t.string :id_usu
      t.integer :id_ope
      t.integer :id_res
      t.string :ps
      t.integer :numero
      t.datetime :fecha
      t.string :leg_ope
      t.integer :apagar_in_cents, limit: 8
      t.integer :saldo_in_cents, limit: 8
      t.integer :dif_in_cents, limit: 8
      t.integer :apagarus_in_cents, limit: 8
      t.integer :saldous_in_cents, limit: 8
      t.integer :difus_in_cents, limit: 8
      t.string :ret
      t.string :NOMBRE
      t.string :nom_ope
      t.string :moneda
      t.datetime :fec_sal
      t.string :DET_PREV
      t.string :det_prev2
      t.integer :cobradopes_in_cents, limit: 8
      t.integer :cobradodol_in_cents, limit: 8
      t.integer :pagadopes_in_cents, limit: 8
      t.integer :pagadodol_in_cents, limit: 8
      t.integer :adelantospes_in_cents, limit: 8
      t.integer :difpes_in_cents, limit: 8
      t.integer :difdol_in_cents, limit: 8
      t.integer :marca
      t.string :idusumarca

      t.timestamps null: false
    end
  end
end
