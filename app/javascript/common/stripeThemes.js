export default {
  card: {
    dark: {
      theme: 'none',
      variables: {
        colorBackground: '#17171d',
        colorText: '#e0e6ed',
        borderRadius: '6px',
        colorDanger: '#ec3750'
      },
      rules: {
        '.Input': {
          border: '1px solid transparent'
        },
        '.Input:focus': {
          outline: 'none'
        },
        '.Tab': {
          border: '2px solid transparent'
        },
        '.Tab--selected': {
          borderColor: '#338eda'
        },
        '.Tab:focus': {
          outline: 'none'
        }
      }
    },
    light: {
      theme: 'none',
      variables: {
        colorBackground: '#e0e6ed',
        colorText: '#1f2d3d',
        borderRadius: '6px',
        colorDanger: '#ec3750'
      },
      rules: {
        '.Input': {
          border: '1px solid transparent'
        },
        '.Input:focus': {
          outline: 'none',
          borderColor: '#338eda'
        },
        '.Tab': {
          border: '2px solid transparent'
        },
        '.Tab--selected': {
          borderColor: '#338eda'
        },
        '.Tab:focus': {
          outline: 'none'
        }
      }
    }
  },
  default: {
    dark: {
      theme: 'none',
      variables: {
        colorBackground: '#252429',
        colorText: '#e0e6ed',
        borderRadius: '6px',
        colorDanger: '#ec3750'
      },
      rules: {
        '.Input': {
          border: '1px solid transparent'
        },
        '.Input:focus': {
          outline: 'none',
          borderColor: '#338eda'
        },
        '.Tab': {
          border: '2px solid transparent'
        },
        '.Tab--selected': {
          borderColor: '#338eda'
        },
        '.Tab:focus': {
          outline: 'none'
        }
      }
    },
    light: {
      theme: 'none',
      variables: {
        colorBackground: '#ffffff',
        colorText: '#1f2d3d',
        borderRadius: '6px',
        colorDanger: '#ec3750'
      },
      rules: {
        '.Input': {
          border: '1px solid #e0e6ed'
        },
        '.Input:focus': {
          outline: 'none',
          borderColor: '#338eda'
        },
        '.Tab': {
          border: '2px solid transparent'
        },
        '.Tab--selected': {
          borderColor: '#338eda'
        },
        '.Tab:focus': {
          outline: 'none'
        }
      }
    }
  }
}
