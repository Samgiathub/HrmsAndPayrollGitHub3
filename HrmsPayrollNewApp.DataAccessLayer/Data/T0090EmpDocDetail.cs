using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090EmpDocDetail
{
    public decimal RowId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal DocId { get; set; }

    public string DocPath { get; set; } = null!;

    public string DocComments { get; set; } = null!;

    public DateTime? DateOfExpiry { get; set; }

    public DateOnly? DocUploadDateTime { get; set; }

    public bool? Verify { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0040DocumentMaster Doc { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;
}
