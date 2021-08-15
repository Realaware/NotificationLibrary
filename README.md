# NotificationLibrary
simple, easy to use.

# How to use

Example code

```lua
   local Load = loadstring(game:HttpGet('https://raw.githubusercontent.com/jiwonpaly/NotificationLibrary/main/main.lua'))();
   local Library = Load.new({
      PaddingItem: number
   }) -- config.
   
   Library:addNoti({
      Title: string,
      Content: string,
      Duration: number,
      Bar color: Color3
   });
   
   
```
