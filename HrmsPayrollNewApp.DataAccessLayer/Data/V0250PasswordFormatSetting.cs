using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0250PasswordFormatSetting
{
    public string? Format { get; set; }

    public string? Name { get; set; }

    public string? FormatId { get; set; }

    public int? CmpId { get; set; }

    public int PwdId { get; set; }

    public string? PageName { get; set; }
}
