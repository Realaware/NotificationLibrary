local Library = {
    Notifications = {}
};
local Animations = {};
Library.__index = Library;

function CreateInstance(instance: string, Properties: table, Children: table) 
    local Object = Instance.new(instance);

    for Index, Value in pairs (Properties or {}) do
        Object[Index] = Value;
    end

    for Index, Child in pairs (Children or {}) do
        Child.Parent = Object;
    end

    return Object;
end



type BasicProps = {
    MaxItems: number?,
    PaddingItem: number?,
}

type NotificationProps = {
    Title: string,
    Content: string,
    Duration: number,
    BarColor: Color3?,
}

function Library:RearrangeItems()
    for Index, Value in pairs (self.Notifications) do
        local Item: Frame = Value.Container;
        if (Item) then
            local PaddingItem = self.Config.PaddingItem or 5;

            Tween(Item, { Position = UDim2.new(1, -20, 1,  (-(65 + PaddingItem) * Index )) }, 0.3);
        end
    end
end

function Library.new(Config: BasicProps)
    if (not Config) then
        Config = { MaxItems = math.huge, PaddingItem = 5 };
    end

    local Container = CreateInstance('ScreenGui', {
        Name = 'Notification',
        Parent = game:GetService('CoreGui'),
    }, {
        CreateInstance('Frame', {
            Name = 'Container',
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1.000,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(1, 0, 1, 0),
        })
    })

    Container.Container.ChildAdded:Connect(function()
        wait(.2);
        Library:RearrangeItems();
    end)

    Container.Container.ChildRemoved:Connect(function()
        Library:RearrangeItems();
    end)

    return setmetatable({
        Container = Container.Container,
        Config = Config,
    }, Library)
end

function Tween(instance: Instance, Properties, Duration: number, ...)
    local Tween = game:GetService('TweenService'):Create(instance, TweenInfo.new(Duration, ...), Properties);
    Tween:Play();

    return Tween;
end

function CreateNotiItem(Library, Config: NotificationProps)
    if (Library.Config.MaxItems and Library.Config.MaxItems == #Library.Notifications) then return end;
    local Container = CreateInstance('Frame', {
        Name = 'Item',
        AnchorPoint = Vector2.new(1, 0.5),
        Parent = Library.Container,
        BackgroundColor3 = Color3.fromRGB(22, 22, 22),
        Position = UDim2.new(1, -20, 1, -65),
        Size = UDim2.new(0, 0, 0, 65),
        ClipsDescendants = true,
    }, {
        CreateInstance('TextLabel', {
            Name = 'Title',
            AnchorPoint = Vector2.new(0.5, 0),
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 0, 0, 0),
            Size = UDim2.new(1, 0, 0, 20),
            Font = Enum.Font.SourceSansSemibold,
            TextColor3 = Color3.fromRGB(213, 213, 213),
            TextSize = 16.000,
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = Config.Title,
        }, {
            CreateInstance('UIPadding', {
                PaddingLeft = UDim.new(0, 5)
            })
        }),
        CreateInstance('Frame', {
            Name = 'ProgressBar',
            BackgroundColor3 = Config.BarColor or Color3.fromRGB(38, 85, 166),
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0.3, 0),
            Size = UDim2.new(0, 0, 0, 2),
        }),
        CreateInstance('TextLabel', {
            Name = 'Content',
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0.33, 0),
            Size = UDim2.new(1, 0, 0, 43),
            Font = Enum.Font.SourceSansSemibold,
            TextColor3 = Color3.fromRGB(213, 213, 213),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            Text = Config.Content,
            TextSize = 15,
        }, {
            CreateInstance('UIPadding', {
                PaddingTop = UDim.new(0, 3),
                PaddingLeft = UDim.new(0, 5),
            })
        }),
        CreateInstance('UICorner', {
            CornerRadius = UDim.new(0, 3)
        })
    });

    local Title: TextLabel = Container.Title;
    local Content: TextLabel = Container.Content;
    local TextService = game:GetService('TextService');
    local Duration: number = Config.Duration;
    
    local Size = TextService:GetTextSize(Title.Text, Title.TextSize, Title.Font, Vector2.new(math.huge, Title.Size.Y));
    local Size2 = TextService:GetTextSize(Content.Text, Content.TextSize, Content.Font, Vector2.new(math.huge, Content.Size.Y));
    
    local MinSize = {0, 240, 0, 65};
    local TweenSize = {0, 0, 0, 65};

    if (Size.X > Size2.X) then
        TweenSize[2] = math.clamp(Size.X + 10, MinSize[2], math.huge);
    elseif (Size.X < Size2.X) then
        TweenSize[2] = math.clamp(Size2.X + 10, MinSize[2], math.huge);
    end

    wait(.05);
    local key = Library:RandomString(10);
    table.insert(Library.Notifications, {
        Container = Container,
        Config = Config,
        key = key,
    })

    Tween(Container, { Size = UDim2.new(unpack(TweenSize)) }, 0.3).Completed:Connect(function()
        Tween(Container.ProgressBar, { Size = UDim2.new(1, 0, 0, 2) }, Duration or 5).Completed:Connect(function()
            Tween(Container, { Size = UDim2.new(0, 0, 0, 65) }, 0.7).Completed:Connect(function()
                for Index, Value in pairs (Library.Notifications) do
                    if (Value.key == key) then
                        table.remove(Library.Notifications, Index);
                        break;
                    end
                end
                Container:Destroy();
            end)
        end)
    end)

end

function Library:addNoti(...)
    local Notification = CreateNotiItem(self, ...);
    
    return Notification;
end

local charset = {}  do
    for c = 48, 57  do table.insert(charset, string.char(c)) end
    for c = 65, 90  do table.insert(charset, string.char(c)) end
    for c = 97, 122 do table.insert(charset, string.char(c)) end
end

function Library:RandomString(length)
    if not length or length <= 0 then return '' end
    return self:RandomString(length - 1) .. charset[math.random(1, #charset)]
end

function Library:RandomTable(length)
    local result = {};
    for i = 1, length do
        table.insert(result, self:RandomString(math.random(1, 10)));
    end

    return result;
end

return Library;
