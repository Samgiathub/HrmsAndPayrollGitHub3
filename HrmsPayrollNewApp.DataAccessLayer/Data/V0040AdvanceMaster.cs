using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040AdvanceMaster
{
    public decimal EmpId { get; set; }

    public string? EmpFullName { get; set; }

    public decimal? REmpId { get; set; }

    public decimal CmpId { get; set; }
}
