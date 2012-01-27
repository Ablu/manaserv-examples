require "luasql.mysql"

DB_NAME = "mana"
DB_USER = "mana"
DB_PASSWORD = "testtest"
DB_HOST = "localhost"
DB_TABLE = "mana_scripts_flowers"

mFlowerList = {}

function init()
    mMapId = mana.get_map_id()
end

function initDBConnection()
    env = luasql.mysql()
    conn = env:connect(DB_NAME, DB_USER, DB_PASSWORD, DB_HOST)
end

function recreateFlowers()
    local sql = "SELECT id, x, y FROM " .. DB_TABLE .. " WHERE map_id=" .. mMapId .. ";"
    local query = conn:execute(sql)
    local row = {}
    row = query:fetch(row)
    while row do
        local id = row[1]
        local x = row[2]
        local y = row[3]
        local flower = mana.monster_create(row[1], row[2], row[3])
        mFlowerList[x] = {}
        mFlowerList[y] = {id=id, handle=flower}
        mana.log(LOGLEVEL_DEBUG, string.format("recreated flowerid %u at %u|%u", id, x, y))
        row = query:fetch(row)
    end
end

function deleteFlower(id, x, y)
    mFlowerList[x][y] = nil
    local sql = "DELETE FROM " .. DB_TABLE ..
                " WHERE map_id=" .. mMapId ..
                " AND x=" .. x .. " AND y=" .. y ..";"
    conn:execute(sql)
end


function growFlower(new_id, x, y)
    mana.monster_remove(mFlowerList[x][y].handle)
    local new_handle = mana.monster_create(new_id, x, y)
    mFlowerList[x][y].id = new_id
    mFlowerList[x][y].handle = new_handle
end










