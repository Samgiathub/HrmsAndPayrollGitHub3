using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0095EmpPrivilegeOtherCmp
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal OCmpId { get; set; }

    public decimal OPrivilegeId { get; set; }

    public byte IsActive { get; set; }

    public DateTime SystemDate { get; set; }

    public DateTime? LastUpdated { get; set; }

    public decimal LoginId { get; set; }
}
