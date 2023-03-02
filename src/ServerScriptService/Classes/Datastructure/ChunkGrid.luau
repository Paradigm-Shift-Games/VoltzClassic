local ChunkGrid = {}
ChunkGrid.__index = ChunkGrid

export type ChunkGrid = {
    ChunkSize: Vector3,
    Chunks: {[Vector3]: {[Vector3]: boolean}},
    Insert: (position: Vector3) -> (),
    IsInRange: (position: Vector3, range: number) -> boolean,
}

function ChunkGrid.new(chunkSize: Vector3)
    local self = setmetatable({}, ChunkGrid)
    self.ChunkSize = chunkSize
    self.Chunks = {}
    return self
end

function ChunkGrid:_getChunkCoord(position: Vector3)
    local chunkPosition = position / self.ChunkSize
    return Vector3.new(math.floor(chunkPosition.X), math.floor(chunkPosition.Y), math.floor(chunkPosition.Z))
end

function ChunkGrid:Insert(position: Vector3)
    local chunk = self:_getChunkCoord(position)

    if not self.Chunks[chunk] then
        self.Chunks[chunk] = {}
    end

    self.Chunks[chunk][position] = true
end

function ChunkGrid:IsInRange(position: Vector3, range: number): boolean
    local lowerBound = position - Vector3.new(range, range, range)
    local upperBound = position + Vector3.new(range, range, range)

    for x = lowerBound.X, upperBound.X, self.ChunkSize.X do
        for y = lowerBound.Y, upperBound.Y, self.ChunkSize.Y do
            for z = lowerBound.Z, upperBound.Z, self.ChunkSize.Z do
                local chunk = self.Chunks[Vector3.new(x, y, z)]

                if not chunk then
                    continue
                end

                for chunkPosition, _ in chunk do
                    if (chunkPosition - position).Magnitude < range then
                        return true
                    end
                end
            end
        end
    end

    return false
end

function ChunkGrid:GetElements(): {Vector3}
    local elements = {}

    for _, chunk in self.Chunks do
        for position, _ in chunk do
            table.insert(elements, position)
        end
    end
    
    return elements
end

return ChunkGrid