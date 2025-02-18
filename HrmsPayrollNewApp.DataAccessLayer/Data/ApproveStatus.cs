using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class ApproveStatus
{
    public int ApprStatusId { get; set; }

    public string StatusName { get; set; } = null!;
}
