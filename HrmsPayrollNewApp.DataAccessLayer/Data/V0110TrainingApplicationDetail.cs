using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0110TrainingApplicationDetail
{
    public decimal EmpId { get; set; }

    public decimal? TrainingAppId { get; set; }

    public decimal TranAppDetailId { get; set; }

    public decimal CmpId { get; set; }

    public string? EmpFullName { get; set; }

    public decimal EmpCode { get; set; }
}
