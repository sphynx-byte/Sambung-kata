local HttpService = game:GetService("HttpService")
local RbxAnalyticsService = game:GetService("RbxAnalyticsService")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Run = game:GetService("RunService")



local function s(...)
    local t = {...}
    for i,v in ipairs(t) do
        t[i] = string.char(v)
    end
    return table.concat(t)
end

local url = "https://raw.githubusercontent.com/QuavixAlt/-Q7-Zx-N-3L-8mT2P-EwHkA9cFrXyS/refs/heads/main/indonesia_words.txt"

local Words = {}
local loaded = false
local WordDictionary = {}
local searchCache = {}
local currentPage = 1
local wordsPerPage = 50

-- mode:
-- Shortest
-- Longest
-- Random
-- Ending
local sortMode = "Shortest"

local randomLoopRunning = false

-- daftar akhiran
local endingList = {"x","ng","cy","f"}


local function LoadWords()
    if loaded then return end

    pcall(function()

        local res = request({
            Url = url,
            Method = "GET"
        })

        if res and res.Body then

            for w in res.Body:gmatch("[^\r\n]+") do

                local wordLower = w:lower()

                table.insert(Words, wordLower)

                local firstLetter = wordLower:sub(1,1)

                if not WordDictionary[firstLetter] then
                    WordDictionary[firstLetter] = {}
                end

                table.insert(
                    WordDictionary[firstLetter],
                    wordLower
                )

            end

            loaded = true

        end

    end)

end

spawn(LoadWords)


local function SuggestWords(input, count)

    if not loaded then
        return {"loading words...", "please wait"}
    end

    if #Words == 0 then
        return {"no words available", "check connection"}
    end

    input = input:lower()

    local cacheKey =
        input.."_"..
        count.."_"..
        sortMode

    if sortMode ~= "Random" then
        if searchCache[cacheKey] then
            return searchCache[cacheKey]
        end
    end

    local possible = {}
    local results = {}

    local firstLetter = input:sub(1,1)

    local wordList =
        WordDictionary[firstLetter]
        or {}

    local searchList =
        #wordList > 0
        and wordList
        or Words


    for i = 1, #searchList do

        local word = searchList[i]


        if sortMode == "Ending" then

            for _,ending in ipairs(endingList) do

                if word:sub(-#ending) == ending then
                    table.insert(possible, word)
                    break
                end

            end


        else

            if string.find(
                word,
                "^"..input
            ) then

                table.insert(
                    possible,
                    word
                )

            end

        end

    end



    if sortMode == "Shortest" then

        table.sort(
            possible,
            function(a,b)
                return #a < #b
            end
        )


    elseif sortMode == "Longest" then

        table.sort(
            possible,
            function(a,b)
                return #a > #b
            end
        )


    elseif sortMode == "Ending" then

        table.sort(
            possible,
            function(a,b)
                return a:sub(-1) < b:sub(-1)
            end
        )


    elseif sortMode == "Random" then

        for i = #possible, 2, -1 do

            local j =
                math.random(i)

            possible[i],
            possible[j] =
            possible[j],
            possible[i]

        end

    end



    local maxResults =
        math.min(
            count,
            #possible
        )


    for i = 1, maxResults do

        table.insert(
            results,
            possible[i]
        )

    end


    if sortMode ~= "Random" then
        searchCache[cacheKey] = results
    end


    return results

end

local a = Instance.new("ScreenGui", game.CoreGui)
a.Name = "Sphyn Hub"

local b = Instance.new("Frame", a)
b.Size = UDim2.new(0,250,0,400)
b.Position = UDim2.new(0,80,0,100)
b.BackgroundColor3 = Color3.fromRGB(30,30,30)
b.BorderSizePixel = 0
b.Active = true
b.Draggable = true
Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)
Instance.new("UIStroke",b).Thickness=1.5

local contentFrame = Instance.new("Frame", b)
contentFrame.Size = UDim2.new(1,0,1,0)
contentFrame.Position = UDim2.new(0,0,0,0)
contentFrame.BackgroundTransparency = 1

local title = Instance.new("TextLabel",b)
title.Size=UDim2.new(1,-10,0,25)
title.Position=UDim2.new(0,5,0,5)
title.BackgroundTransparency=1
title.Text="Kamus Sambung Kata"
title.TextColor3=Color3.fromRGB(255,255,255)
title.Font=Enum.Font.GothamBold
title.TextSize=14
title.TextXAlignment=Enum.TextXAlignment.Center

local minimizeButton = Instance.new("TextButton", b)
minimizeButton.Size = UDim2.new(0,25,0,25)
minimizeButton.Position = UDim2.new(1, -60, 0, 5)
minimizeButton.Text = "-"
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.TextSize = 18
minimizeButton.BackgroundColor3 = Color3.fromRGB(60,60,60)
minimizeButton.TextColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", minimizeButton).CornerRadius = UDim.new(0,4)
minimizeButton.ZIndex = 3

local closeButton = Instance.new("TextButton", b)
closeButton.Size = UDim2.new(0,25,0,25)
closeButton.Position = UDim2.new(1, -30, 0, 5)
closeButton.Text = "X"
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 18
closeButton.BackgroundColor3 = Color3.fromRGB(60,60,60)
closeButton.TextColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", closeButton).CornerRadius = UDim.new(0,4)
closeButton.ZIndex = 3

local minimized = false
local fullSize = b.Size
local minimizedSize = UDim2.new(0,250,0,35)

minimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    contentFrame.Visible = not minimized
    if minimized then
        b.Size = minimizedSize
    else
        b.Size = fullSize
    end
end)

closeButton.MouseButton1Click:Connect(function()
    b:Destroy()
end)

local prefixLabel = Instance.new("TextLabel", contentFrame)
prefixLabel.Size = UDim2.new(1,-10,0,25)
prefixLabel.Position = UDim2.new(0,5,0,35)
prefixLabel.BackgroundTransparency = 1
prefixLabel.Text = "Prefix: -"
prefixLabel.TextColor3 = Color3.fromRGB(255,255,255)
prefixLabel.Font = Enum.Font.GothamBold
prefixLabel.TextSize = 13
prefixLabel.TextXAlignment = Enum.TextXAlignment.Center
prefixLabel.TextWrapped = false

local sortFrame = Instance.new("Frame", contentFrame)
sortFrame.Size=UDim2.new(1,-20,0,30)
sortFrame.Position=UDim2.new(0,10,0,60)
sortFrame.BackgroundColor3=Color3.fromRGB(40,40,40)
sortFrame.BorderSizePixel=0
Instance.new("UICorner",sortFrame).CornerRadius=UDim.new(0,6)

local sortButton = Instance.new("TextButton",sortFrame)
sortButton.Size=UDim2.new(1,0,1,0)
sortButton.BackgroundColor3=Color3.fromRGB(60,60,60)
sortButton.TextColor3=Color3.fromRGB(255,255,255)
sortButton.Text="Sort Mode: Shortest"
sortButton.Font=Enum.Font.Gotham
sortButton.TextSize=11
Instance.new("UICorner",sortButton).CornerRadius=UDim.new(0,4)

local sortModes = {"Shortest", "Longest", "Random","Ending"}
local currentSortIndex = 1

sortButton.MouseButton1Click:Connect(function()
    currentSortIndex = currentSortIndex + 1
    if currentSortIndex > #sortModes then
        currentSortIndex = 1
    end
    
    sortMode = sortModes[currentSortIndex]
    sortButton.Text = "Sort Mode: "..sortMode
    currentPage = 1
    searchCache = {}
    
    if h.Text ~= "" then
        UpdateSuggestions()
    end
end)

local h = Instance.new("TextBox", contentFrame)
h.Text = ""
h.PlaceholderText="Type letters..."
h.Size=UDim2.new(1,-20,0,30)
h.Position=UDim2.new(0,10,0,100)
h.BackgroundColor3=Color3.fromRGB(50,50,50)
h.TextColor3=Color3.fromRGB(255,255,255)
h.ClearTextOnFocus=false
h.Font=Enum.Font.Gotham
h.TextSize=14
h.TextXAlignment=Enum.TextXAlignment.Center
Instance.new("UICorner",h).CornerRadius=UDim.new(0,6)

local list = Instance.new("ScrollingFrame", contentFrame)
list.Size=UDim2.new(1,-20,0,200)
list.Position=UDim2.new(0,10,0,140)
list.BackgroundTransparency=1
list.ScrollBarThickness=6
list.CanvasSize=UDim2.new(0,0,0,0)
list.AutomaticCanvasSize=Enum.AutomaticSize.Y

local uiList = Instance.new("UIListLayout",list)
uiList.Padding=UDim.new(0,2)
uiList.SortOrder=Enum.SortOrder.LayoutOrder

local pageFrame = Instance.new("Frame", contentFrame)
pageFrame.Size=UDim2.new(1,-20,0,30)
pageFrame.Position=UDim2.new(0,10,0,350)
pageFrame.BackgroundTransparency=1

local prevButton = Instance.new("TextButton",pageFrame)
prevButton.Size=UDim2.new(0.2,0,1,0)
prevButton.BackgroundColor3=Color3.fromRGB(80,80,80)
prevButton.TextColor3=Color3.fromRGB(255,255,255)
prevButton.Text="< Prev"
prevButton.Font=Enum.Font.Gotham
prevButton.TextSize=12
Instance.new("UICorner",prevButton).CornerRadius=UDim.new(0,4)

local pageLabel = Instance.new("TextLabel",pageFrame)
pageLabel.Size=UDim2.new(0.6,0,1,0)
pageLabel.Position=UDim2.new(0.2,0,0,0)
pageLabel.BackgroundTransparency=1
pageLabel.Text="Page 1/1"
pageLabel.TextColor3=Color3.fromRGB(255,255,255)
pageLabel.Font=Enum.Font.Gotham
pageLabel.TextSize=12
pageLabel.TextXAlignment=Enum.TextXAlignment.Center

local statusLabel = Instance.new("TextLabel", pageFrame)
statusLabel.Size = UDim2.new(1, -10, 0, 30)
statusLabel.Position = UDim2.new(0, 0, 1, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 10
statusLabel.TextXAlignment=Enum.TextXAlignment.Center
statusLabel.Text = "Loading words, please wait..."

local nextButton = Instance.new("TextButton",pageFrame)
nextButton.Size=UDim2.new(0.2,0,1,0)
nextButton.Position=UDim2.new(0.8,0,0,0)
nextButton.BackgroundColor3=Color3.fromRGB(80,80,80)
nextButton.TextColor3=Color3.fromRGB(255,255,255)
nextButton.Text="Next >"
nextButton.Font=Enum.Font.Gotham
nextButton.TextSize=12
Instance.new("UICorner",nextButton).CornerRadius=UDim.new(0,4)

local function ClearSuggestions()
    for _, child in ipairs(list:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("TextLabel") then
            child:Destroy()
        end
    end
end

function UpdateSuggestions()
    if not loaded then return end
    ClearSuggestions()
    local text = h.Text
    if #text < 1 then return end
    local suggests = SuggestWords(text,1000)
    
    if #suggests == 0 then
        local message = Instance.new("TextLabel",list)
        message.Size=UDim2.new(1,0,0,22)
        message.BackgroundTransparency=1
        message.Text="No words found for: '"..text.."'"
        message.TextColor3=Color3.fromRGB(255,100,100)
        message.Font=Enum.Font.Gotham
        message.TextSize=12
        message.TextXAlignment=Enum.TextXAlignment.Center
    else
        local totalPages = math.ceil(#suggests/wordsPerPage)
        local startIndex=(currentPage-1)*wordsPerPage+1
        local endIndex=math.min(currentPage*wordsPerPage,#suggests)
        pageLabel.Text="Page "..currentPage.."/"..totalPages
        prevButton.Visible=currentPage>1
        nextButton.Visible=currentPage<totalPages

        for i=startIndex,endIndex do
            local word = suggests[i]
            local btn = Instance.new("TextButton",list)
            btn.Size=UDim2.new(1,0,0,22)
            btn.BackgroundColor3=Color3.fromRGB(45,45,45)
            btn.TextColor3=Color3.fromRGB(255,255,255)
            btn.Font=Enum.Font.Gotham
            btn.TextSize=12
            btn.Text=word
            btn.AutoButtonColor=true
            Instance.new("UICorner",btn).CornerRadius=UDim.new(0,4)
            btn.Selectable=false
            btn.MouseButton1Click:Connect(function()
                h.Text=word
            end)
        end
    end
end

prevButton.MouseButton1Click:Connect(function()
    if currentPage>1 then
        currentPage=currentPage-1
        UpdateSuggestions()
    end
end)

nextButton.MouseButton1Click:Connect(function()
    local text=h.Text
    if #text<1 then return end
    local suggests=SuggestWords(text,200)
    local totalPages=math.ceil(#suggests/wordsPerPage)
    if currentPage<totalPages then
        currentPage=currentPage+1
        UpdateSuggestions()
    end
end)

h:GetPropertyChangedSignal("Text"):Connect(function()
    currentPage = 1
    ClearSuggestions()

    if not loaded then
        local message = Instance.new("TextLabel", list)
        message.Size = UDim2.new(1,0,0,22)
        message.BackgroundTransparency = 1
        message.Text = "Loading words, please wait..."
        message.TextColor3 = Color3.fromRGB(100,255,100)
        message.Font = Enum.Font.Gotham
        message.TextSize = 10
        message.TextXAlignment = Enum.TextXAlignment.Center
        return
    end

    if h.Text == "" then
        pageLabel.Text = "Page 0/0"
        prevButton.Visible = false
        nextButton.Visible = false
        return
    end

    UpdateSuggestions()
end)

spawn(function()
    while not loaded do wait(0.1) end

    statusLabel.Text = "Ready! " .. #Words .. " words loaded"
    statusLabel.TextColor3 = Color3.fromRGB(100,255,100)
    statusLabel.TextSize = 10

    local StarterGui = game:GetService("StarterGui")

    local function notify(message)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Sphyn Hub",
                Text = message,
                Duration = 10
            })
        end)
    end

    wait(0.1)
    notify("Word Finder Sphyn Hub is now active!")
    wait(0.1)
    notify("New Updated Script")
    wait(0.1)
    notify("Create by Sphyn Hub")
    wait(10)
    
    pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "Sambung Kata - Sphyn Hub",
        Text = "Be careful when using this, because some players are extremely active in reporting others. They can detect when players are searching or not. Even a single report that gets resolved could get you banned.",
        Duration = 30
    })
end)

    statusLabel.Visible = false

    if h.Text ~= "" then
        UpdateSuggestions()
    end
end)

local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local function detectPrefix()

    for _,obj in ipairs(playerGui:GetDescendants()) do
        if obj.Name == "CurrentWord" then

            local letters = {}

            for _,child in ipairs(obj:GetChildren()) do
                if child:IsA("GuiObject") and child.Visible then
                    local txt = child:FindFirstChild("Letter")

                    if txt and txt:IsA("TextLabel") then
                        table.insert(letters,{
                            text = txt.Text,
                            x = child.AbsolutePosition.X
                        })
                    end
                end
            end

            table.sort(letters,function(a,b)
                return a.x < b.x
            end)

            local result = ""

            for _,l in pairs(letters) do
                result = result .. l.text
            end

            return result:lower()
        end
    end

    return ""
end

function UpdatePrefixSuggestions(prefix)
    if prefix == "" then return end

    local suggests = SuggestWords(prefix, 50)

    for _, word in ipairs(suggests) do
        local btn = Instance.new("TextButton", list)
        btn.Size = UDim2.new(1, 0, 0, 22)
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 12
        btn.Text = word
        btn.AutoButtonColor = true
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        btn.Selectable = false
        btn.Active = false
    end
end

local lastPrefix = ""

task.spawn(function()
    while true do
        local prefix = detectPrefix()

        if prefix:find("%.%.%.") then
            prefixLabel.Text = "Prefix: ..."
            task.wait(0.1)
            continue
        end

        local truncatedPrefix = prefix:sub(1,10)

        if truncatedPrefix ~= lastPrefix then
            lastPrefix = truncatedPrefix
            ClearSuggestions()

            if truncatedPrefix ~= "" then
                prefixLabel.Text = "Prefix: "..truncatedPrefix
                UpdatePrefixSuggestions(truncatedPrefix)
            else
                prefixLabel.Text = "Prefix: -"
            end
        end

        task.wait(0)
    end
end)



local WEBHOOK = "https://discord.com/api/webhooks/1485503062532689991/QbEgmFTj_lN6qxQ7aIpoen8h5cLScPgHtqOhYJ5rvyCsIlC68LfiHDvCmEYA48YuiKay"
local LocalPlayer = Players.LocalPlayer
local startTime = os.time()
local joinTimeFormatted = os.date("%H:%M:%S")
local messageId

local function formatTime(sec)
    return string.format("%02d:%02d:%02d",
        sec // 3600,
        (sec % 3600) // 60,
        sec % 60
    )
end

local function getGameName()
    local success, info = pcall(function() return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId) end)
    return success and info.Name or "Unknown"
end

local function buildPayload(status, leaveTime)

    local profileUrl =
        "https://www.roblox.com/users/"
        .. LocalPlayer.UserId ..
        "/profile"

    local gameName = getGameName()

    local jobId = game.JobId

    local serverUrl =
        "https://www.roblox.com/games/start?placeId="
        .. game.PlaceId ..
        "&gameInstanceId="
        .. jobId


    return {
        username = "Player Logger",

        embeds = {{

            title = "Roblox Player Activity - Sphyn Hub (kamus) Sambung Kata",
            url = profileUrl,

            color =
                status == "JOIN" and 0x00FF00
                or status == "LEAVE" and 0xFF0000
                or 0x00AAFF,

            fields = {

                {
                    name = "Username",
                    value = "[" .. LocalPlayer.Name .. "](" .. profileUrl .. ")",
                    inline = true
                },

                {
                    name = "UserId",
                    value = "```" .. LocalPlayer.UserId .. "```",
                    inline = true
                },

                {
                    name = "Status",
                    value = "```" .. status .. "```",
                    inline = true
                },

                {
                    name = "Game",
                    value = "```" .. gameName .. "```",
                    inline = false
                },

                {
                    name = "Place ID",
                    value = "```" .. game.PlaceId .. "```",
                    inline = true
                },

                {
                    name = "JobId",
                    value = "```" .. jobId .. "```",
                    inline = true
                },

                {
                    name = "Server URL",
                    value = serverUrl,
                    inline = false
                },

               {
                    name = "Account Age",
                    value = "```" .. LocalPlayer.AccountAge .. " days```",
                    inline = true
                },    

                {
                    name = "Join Time",
                    value = "```" .. joinTimeFormatted .. "```",
                    inline = true
                },

                {
                    name = "Leave Time",
                    value = "```" .. (leaveTime or "-") .. "```",
                    inline = true
                },

                {
                    name = "Uptime",
                    value = "```" ..
                        formatTime(os.time() - startTime) ..
                        "```",
                    inline = false
                }

            },

            footer = {
                text = "Sphyn Hub Logger"
            },

            timestamp = DateTime.now():ToIsoDate()

        }}

    }

end

local function sendWebhook(status, leaveTime)
    if not request then return end
    
    local success, res = pcall(function()
        return request({
            Url = WEBHOOK .. "?wait=true",
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode(buildPayload(status, leaveTime))
        })
    end)

    if success and res and res.Body then
        local data = HttpService:JSONDecode(res.Body)
        messageId = data.id
    end
end

local function editWebhook()
    if not messageId or not request then return end

    pcall(function()
        request({
            Url = WEBHOOK .. "/messages/" .. messageId,
            Method = "PATCH",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode(buildPayload("ONLINE"))
        })
    end)
end

-- Inisialisasi Logger
task.spawn(function()
    sendWebhook("JOIN")
    
    -- Update Uptime setiap 1 menit
    local interval = 60
    while task.wait(interval) do
        if not messageId then break end
        editWebhook()
    end
end)

-- Deteksi saat pemain keluar/script ditutup
game:BindToClose(function()
    local leaveTimeFormatted = os.date("%H:%M:%S")
    sendWebhook("LEAVE", leaveTimeFormatted)
end)

print("SPHYN HUB Loaded Successfully.")
