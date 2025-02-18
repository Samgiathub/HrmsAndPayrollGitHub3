using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0011CompanyMdDetail
{
    public decimal MdId { get; set; }

    public decimal CmpId { get; set; }

    public string MdName { get; set; } = null!;

    public string MdDesignation { get; set; } = null!;

    public string MdStreet1 { get; set; } = null!;

    public string MdStreet2 { get; set; } = null!;

    public string MdStreet3 { get; set; } = null!;

    public string MdCity { get; set; } = null!;

    public string MdState { get; set; } = null!;

    public string MdPinCode { get; set; } = null!;

    public string MdTelNo { get; set; } = null!;

    public string MdEmail { get; set; } = null!;

    public decimal MdShare { get; set; }

    public byte MdType { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;
}
