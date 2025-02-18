using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0251ItPaidDetail
{
    public decimal TranId { get; set; }

    public decimal ItPaidId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal ETaxableAmount { get; set; }

    public decimal EItAmount { get; set; }

    public decimal EItSurcharge { get; set; }

    public decimal EItEdCess { get; set; }

    public decimal ETotalItAmount { get; set; }

    public decimal EItPaidAmount { get; set; }

    public string EItComments { get; set; } = null!;

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0250ItPaid ItPaid { get; set; } = null!;
}
