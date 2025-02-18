using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0300NocApprovalGet
{
    public decimal? CmpId { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public decimal EmpId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? BranchId { get; set; }
}
