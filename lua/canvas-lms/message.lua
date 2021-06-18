--- Canvas LMS in Lua: Messaging
-- @submodule canvas

local canvas = {}


function canvas:message_group_wfile(send_check,msg)

  local function encode(str)
		str = string.gsub (str, "\n", "\r\n")
    str = string.gsub(str, "([^%w _ %- . ~])",
      function (c) return string.format ("%%%02X", string.byte(c)) end
    )
    str = string.gsub (str, " ", "+")
	  return str
	end


  local recipients="recipients[]=group_"..msg.canvasid
  local subject="subject="..msg.subject
  local body="body="..msg.body

  local attachfile = self:get("users/self/files","search_term="..msg.filestub)
  if #attachfile > 0 then
    local fileid = "attachment_ids[]="..attachfile[1].id
    local isgroup = "group_conversation=true"

    local opt = recipients.."&"..subject.."&"..body.."&"..fileid.."&"..isgroup

    if send_check=="y" then
      self:post("conversations",encode(opt))
    else
      print("MESSAGE:")
      print(opt)
      print("AFTER ENCODING:")
      print(encode(opt))
      print("NOT SENT ACCORDING TO USER INSTRUCTIONS")
    end
  else
    error("No file found")
  end


end

--- Message user table arguments.
-- The function `canvas:message_user` takes a table of arguments to define the message to send.
-- The table may consist of the following
-- @field canvasid The Canvas ID of the recipient (reqd)
-- @field subject  The subject of the message to send
-- @field body     The body text of the message to send
-- @field course   The Canvas course ID to send from (defaults to defined course)
-- @table @{message_user_args}

--- Message a specific Canvas user.
-- @tparam bool send_check Toggle whether to truly send the message or just to pretty print it to the screen
-- @tparam table msg table with entries to define message according to @{message_user_args}
function canvas:message_user(send_check,msg)

  local function encode(str)
		str = string.gsub (str, "\n", "\r\n")
    str = string.gsub(str, "([^%w _ %- . ~])",
      function (c) return string.format ("%%%02X", string.byte(c)) end
    )
    str = string.gsub (str, " ", "+")
	  return str
	end

  local forcenew="bulk_message=true&force_new=true"
  local recipients="recipients[]="..msg.canvasid
  local subject="subject="..encode(msg.subject)
  local body="body="..encode(msg.body)
  local opt = forcenew.."&"..recipients.."&"..subject.."&"..body

  if msg.context then
    opt = opt.."&context_code="..encode(msg.context)
  elseif msg.course then
    opt = opt.."&context_code=course_"..msg.course
  else
    opt = opt.."&context_code=course_"..self.courseid
  end

  if send_check then
    self:post("conversations",opt)
  else
    print("=========== FACSIMILE OF MESSAGE NOT SENT ===========")
    print("Subject: "..msg.subject.."\n")
    print("=====================================================")
    print(msg.body)
  end


end

return canvas
