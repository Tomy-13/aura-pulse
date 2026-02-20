class CreateEarthquakes < ActiveRecord::Migration[8.1]
  def change
    create_table :earthquakes do |t|
      t.string :external_id
      t.decimal :magnitude
      t.string :place
      t.string :continent
      t.datetime :occurred_at
      t.boolean :is_verified, default: false
      
      # El array clave para tu globo 3D [longitud, latitud, profundidad]
      t.decimal :coordinates, array: true, default: []

      t.timestamps
    end
    
    # Índice para buscar rapidísimo y no duplicar sismos
    add_index :earthquakes, :external_id, unique: true
  end
end