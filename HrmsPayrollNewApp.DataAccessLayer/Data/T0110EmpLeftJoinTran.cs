using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0110EmpLeftJoinTran
{
    public decimal LjTranId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public DateTime JoinDate { get; set; }

    public DateTime? LeftDate { get; set; }

    public decimal? LeftId { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0100LeftEmp? Left { get; set; }
}
