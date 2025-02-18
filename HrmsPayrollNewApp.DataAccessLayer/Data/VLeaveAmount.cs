using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class VLeaveAmount
{
    public decimal? EmpId { get; set; }

    public decimal? PrivilegeLeave { get; set; }

    public decimal? CasualLeave { get; set; }
}
