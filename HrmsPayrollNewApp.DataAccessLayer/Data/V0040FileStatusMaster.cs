using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040FileStatusMaster
{
    public int FStatusId { get; set; }

    public string StatusTitle { get; set; } = null!;

    public string StatusCode { get; set; } = null!;

    public int? CmpId { get; set; }
}
