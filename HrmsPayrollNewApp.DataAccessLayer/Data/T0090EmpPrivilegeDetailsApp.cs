using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090EmpPrivilegeDetailsApp
{
    public long EmpTranId { get; set; }

    public decimal TransId { get; set; }

    public decimal CmpId { get; set; }

    public decimal PrivilegeId { get; set; }

    public DateTime? FromDate { get; set; }

    public int? ApprovedEmpId { get; set; }

    public DateTime? ApprovedDate { get; set; }

    public int? RptLevel { get; set; }

    public virtual T0060EmpMasterApp EmpTran { get; set; } = null!;
}
