using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090EmpPrivilegeDetail
{
    public decimal TransId { get; set; }

    public decimal CmpId { get; set; }

    public decimal LoginId { get; set; }

    public decimal PrivilegeId { get; set; }

    public DateTime? FromDate { get; set; }
}
