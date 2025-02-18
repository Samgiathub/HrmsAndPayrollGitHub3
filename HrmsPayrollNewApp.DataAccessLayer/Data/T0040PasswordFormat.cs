using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040PasswordFormat
{
    public int PwdFrmtId { get; set; }

    public int? CmpId { get; set; }

    public string? Name { get; set; }

    public string? Format { get; set; }
}
