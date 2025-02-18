using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100EmpCompanyLoanTransfer
{
    public decimal RowId { get; set; }

    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal LoanId { get; set; }

    public decimal OldBalance { get; set; }

    public decimal NewCmpId { get; set; }

    public decimal NewEmpId { get; set; }

    public decimal NewLoanId { get; set; }

    public decimal NewBalance { get; set; }

    public decimal LoanRowId { get; set; }

    public decimal? NewLoanAprId { get; set; }

    public virtual T0095EmpCompanyTransfer Tran { get; set; } = null!;
}
