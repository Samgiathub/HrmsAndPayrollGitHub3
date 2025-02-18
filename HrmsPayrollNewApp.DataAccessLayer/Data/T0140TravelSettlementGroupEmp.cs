using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0140TravelSettlementGroupEmp
{
    public int TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal TravelApprovalId { get; set; }

    public decimal TravelApplicationId { get; set; }

    public decimal BranchId { get; set; }

    public DateTime ModifyDate { get; set; }

    public decimal SelectedEmpId { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0120TravelApproval TravelApproval { get; set; } = null!;
}
