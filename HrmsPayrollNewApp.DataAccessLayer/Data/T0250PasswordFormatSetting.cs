using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0250PasswordFormatSetting
{
    public int PwdId { get; set; }

    public int? CmpId { get; set; }

    public string? Name { get; set; }

    public string? FormatId { get; set; }
}
