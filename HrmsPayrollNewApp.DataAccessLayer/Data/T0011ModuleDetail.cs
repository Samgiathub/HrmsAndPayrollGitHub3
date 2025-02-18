using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0011ModuleDetail
{
    public decimal ModuleId { get; set; }

    public string? ModuleName { get; set; }

    public decimal? CmpId { get; set; }

    public int? ModuleStatus { get; set; }

    public int? ChgPwd { get; set; }
}
