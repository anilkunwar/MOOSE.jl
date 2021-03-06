" Implements a Convection operator "
type Convection <: Kernel
    u::Variable

    velocity::Vec{2, Float64}
end

function computeQpResidual(kernel::Convection, qp::Int64, i::Int64)
    u = kernel.u

    return (kernel.velocity ⋅ u.grad[qp]) * u.phi[qp][i]
end

function computeQpJacobian(kernel::Convection, v::Variable, qp::Int64, i::Int64, j::Int64)
    u = kernel.u

    if u.id == v.id
        return (kernel.velocity ⋅ v.grad_phi[qp][j]) * u.phi[qp][i]
    end

    return 0
end
