-- HYDRA Auto Accept Trade V2 - standalone experimental UI helper
-- No anti-cheat bypass. All trades, including empty/unfair offers, may be accepted.
local Players = game:GetService('Players')
local UIS = game:GetService('UserInputService')
local VIM = game:GetService('VirtualInputManager')
local GuiService = game:GetService('GuiService')
local player = Players.LocalPlayer
local pg = player:WaitForChild('PlayerGui')
local old = pg:FindFirstChild('HYDRA_AutoAccept_Standalone')
if old then old:Destroy() end
local gui = Instance.new('ScreenGui')
gui.Name = 'HYDRA_AutoAccept_Standalone'
gui.ResetOnSpawn = false
gui.DisplayOrder = 9999
gui.Parent = pg
local frame = Instance.new('Frame')
frame.Name='Panel'; frame.Size=UDim2.fromOffset(275,145)
frame.Position=UDim2.new(0.5,-137,0.15,0)
frame.BackgroundColor3=Color3.fromRGB(28,22,42)
frame.Active=true; frame.Draggable=true; frame.Parent=gui
Instance.new('UICorner',frame).CornerRadius=UDim.new(0,12)
local function label(text,y,h)
 local l=Instance.new('TextLabel');l.BackgroundTransparency=1;l.TextColor3=Color3.new(1,1,1)
 l.Font=Enum.Font.GothamSemibold;l.TextSize=14;l.Text=text
 l.Position=UDim2.fromOffset(10,y);l.Size=UDim2.new(1,-20,0,h);l.Parent=frame;return l
end
label('HYDRA  |  AUTO TRADE',9,23)
local enabled=false
local button=Instance.new('TextButton');button.Size=UDim2.new(1,-24,0,36)
button.Position=UDim2.fromOffset(12,40);button.BackgroundColor3=Color3.fromRGB(97,60,147)
button.TextColor3=Color3.new(1,1,1);button.Font=Enum.Font.GothamBold;button.TextSize=15
button.Text='AUTO ACCEPT : OFF';button.Parent=frame
Instance.new('UICorner',button).CornerRadius=UDim.new(0,8)
local status=label('Prêt : en attente',83,20);status.TextSize=11
local notice=label('Attention : accepte même les mauvais trades',108,28);notice.TextSize=10
button.MouseButton1Click:Connect(function()
 enabled=not enabled
 button.Text='AUTO ACCEPT : '..(enabled and 'ON' or 'OFF')
 status.Text=enabled and 'Surveillance des demandes...' or 'Désactivé'
end)
local function norm(s)
 return tostring(s or ''):lower():gsub('%s+',' '):gsub('^%s+',''):gsub('%s+$','')
end
local function visible(obj)
 local cur=obj
 while cur and cur~=pg do
  if cur:IsA('GuiObject') and not cur.Visible then return false end
  if cur:IsA('ScreenGui') and not cur.Enabled then return false end
  cur=cur.Parent
 end
 return cur==pg
end
local function textFor(b)
 if b:IsA('TextButton') then return norm(b.Text) end
 for _,d in ipairs(b:GetDescendants()) do
  if d:IsA('TextLabel') then
   local t=norm(d.Text)
   if t~='' then return t end
  end
 end
 return ''
end
local function inTradeContext(b)
 local node=b.Parent
 for depth=1,5 do
  if not node or node==pg then break end
  if norm(node.Name):find('trade',1,true) then return true end
  local scanned=0
  for _,desc in ipairs(node:GetDescendants()) do
   scanned=scanned+1;if scanned>180 then break end
   if desc:IsA('TextLabel') then
    local t=norm(desc.Text)
    if t:find('trade request',1,true) or t:find('wants to trade',1,true)
      or t:find('select brainrots to offer',1,true) or t=='trade' then return true end
   end
  end
  node=node.Parent
 end
 return false
end
local accepted={accept=true,accepter=true,ready=true,confirm=true,confirmer=true,['confirm trade']=true}
local lastClick=setmetatable({},{__mode='k'})
local function attemptClick(b)
 -- Try GUI signal first, then pointer input. Neither guarantees server acceptance.
 if type(firesignal)=='function' then
  local ok=pcall(function() firesignal(b.Activated) end)
  if ok then return true,'signal Activated' end
  ok=pcall(function() firesignal(b.MouseButton1Click) end)
  if ok then return true,'signal MouseButton1Click' end
 end
 local p,s=b.AbsolutePosition,b.AbsoluteSize
 if s.X<=0 or s.Y<=0 then return false,'dimensions invalides' end
 local x,y=p.X+s.X/2,p.Y+s.Y/2
 local ok=pcall(function()
  VIM:SendMouseMoveEvent(x,y,game)
  task.wait(.06)
  VIM:SendMouseButtonEvent(x,y,0,true,game,0)
  task.wait(.12)
  VIM:SendMouseButtonEvent(x,y,0,false,game,0)
 end)
 if ok then return true,'pointer VIM' end
 return false,'input refusé'
end
task.spawn(function()
 while gui.Parent do
  task.wait(.35)
  if enabled then
   local found=false
   for _,b in ipairs(pg:GetDescendants()) do
    if (b:IsA('TextButton') or b:IsA('ImageButton')) and visible(b) then
     local t=textFor(b)
     if accepted[t] and inTradeContext(b) then
      found=true
      if os.clock()-(lastClick[b] or -100)>1.3 then
       lastClick[b]=os.clock()
       status.Text='Bouton détecté : '..t
       local ok,method=attemptClick(b)
       status.Text=(ok and 'Tentative ('..method..') : '..t or 'Echec : '..method)
      end
      break
     end
    end
   end
   if not found then status.Text='En attente : aucun bouton détecté' end
  end
 end
end)
