using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100EmpCompanyTransferSalaryDetail
{
    public decimal RowId { get; set; }

    public decimal TranId { get; set; }

    public decimal OldCmpId { get; set; }

    public decimal OldEmpId { get; set; }

    public decimal OldBasicSalary { get; set; }

    public decimal OldGrossSalary { get; set; }

    public decimal OldCtc { get; set; }

    public decimal NewCmpId { get; set; }

    public decimal NewEmpId { get; set; }

    public decimal NewBasicSalary { get; set; }

    public decimal NewGrossSalary { get; set; }

    public decimal NewCtc { get; set; }

    public virtual T0095EmpCompanyTransfer Tran { get; set; } = null!;
}
